From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [V2 RFC net-next PATCH 2/2] virtio_net: export more statistics
	through ethtool
Date: Thu, 7 Jun 2012 21:56:07 +0100
Message-ID: <1339102567.2770.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120606075208.29081.75284.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120606075217.29081.30713.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<1339089306.2770.10.camel@bwh-desktop.uk.solarflarecom.com>
	<20120607.130512.219951433412203999.davem@davemloft.net>
	<1339100649.2770.20.camel@bwh-desktop.uk.solarflarecom.com>
	<4FD11194.2040405@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4FD11194.2040405@hp.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-06-07 at 13:39 -0700, Rick Jones wrote:
> On 06/07/2012 01:24 PM, Ben Hutchings wrote:
> > On Thu, 2012-06-07 at 13:05 -0700, David Miller wrote:
> >> From: Ben Hutchings<bhutchings@solarflare.com>
> >> Date: Thu, 7 Jun 2012 18:15:06 +0100
> >>
> >>> I would really like to see some sort of convention for presenting
> >>> per-queue statistics through ethtool.  At the moment we have a complete
> >>> mess of different formats:
> >>
> >> Indeed.  Probably ${QUEUE_TYPE}-${INDEX}-${STATISTIC} is best.
> >> With an agreed upon list of queue types such as "rx", "tx", "rxtx"
> >> etc.
> >
> > I think we should leave the type names open-ended, as there are other
> > useful groupings like per-virtual-port.  In that case the separator
> > should be chosen to allow arbitrary type names without ambiguity.
> 
> So you mean like something along the lines of the presence of say '.' 
> indicating indent a level:
> 
> rx_bytes:  1234
>      myqueue1.rx_bytes: 234
>      myqueue2.rx_bytes: 345
>      ...

Most drivers seem to want this sort of ordering/grouping:

group0.foo
group0.bar
...
group1.foo
group1.bar
...

but if we have a standard way of indicating groups of statistics then
the user can choose whether they want to reorder by type name.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
