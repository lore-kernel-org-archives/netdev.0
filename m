From: David Miller <davem@davemloft.net>
Subject: Re: [V2 RFC net-next PATCH 2/2] virtio_net: export more statistics
	through ethtool
Date: Thu, 07 Jun 2012 13:05:12 -0700 (PDT)
Message-ID: <20120607.130512.219951433412203999.davem@davemloft.net>
References: <20120606075208.29081.75284.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120606075217.29081.30713.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<1339089306.2770.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: bhutchings@solarflare.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1339089306.2770.10.camel@bwh-desktop.uk.solarflarecom.com>
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

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 7 Jun 2012 18:15:06 +0100

> I would really like to see some sort of convention for presenting
> per-queue statistics through ethtool.  At the moment we have a complete
> mess of different formats:

Indeed.  Probably ${QUEUE_TYPE}-${INDEX}-${STATISTIC} is best.
With an agreed upon list of queue types such as "rx", "tx", "rxtx"
etc.
