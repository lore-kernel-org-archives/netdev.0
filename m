From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Tue, 20 Dec 2011 13:15:12 +0200
Message-ID: <20111220111512.GA3913@redhat.com>
References: <OF835A6FF5.7D752AD1-ON65257953.0016350C-65257953.00169AF4@in.ibm.com>
	<20111125.013552.1613051198566054931.davem@davemloft.net>
	<20111207161001.GD23845@redhat.com>
	<20111207.135235.557498530764890254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, arnd@arndb.de, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, levinsasha928@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20111207.135235.557498530764890254.davem@davemloft.net>
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

On Wed, Dec 07, 2011 at 01:52:35PM -0500, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Wed, 7 Dec 2011 18:10:02 +0200
> 
> > On Fri, Nov 25, 2011 at 01:35:52AM -0500, David Miller wrote:
> >> From: Krishna Kumar2 <krkumar2@in.ibm.com>
> >> Date: Fri, 25 Nov 2011 09:39:11 +0530
> >> 
> >> > Jason Wang <jasowang@redhat.com> wrote on 11/25/2011 08:51:57 AM:
> >> >>
> >> >> My description is not clear again :(
> >> >> I mean the same vhost thead:
> >> >>
> >> >> vhost thread #0 transmits packets of flow A on processor M
> >> >> ...
> >> >> vhost thread #0 move to another process N and start to transmit packets
> >> >> of flow A
> >> > 
> >> > Thanks for clarifying. Yes, binding vhosts to CPU's
> >> > makes the incoming packet go to the same vhost each
> >> > time. BTW, are you doing any binding and/or irqbalance
> >> > when you run your tests? I am not running either at
> >> > this time, but thought both might be useful.
> >> 
> >> So are we going with this patch or are we saying that vhost binding
> >> is a requirement?
> > 
> > OK we didn't come to a conclusion so I would be inclined
> > to merge this patch as is for 3.2, and revisit later.
> > One question though: do these changes affect userspace
> > in any way? For example, will this commit us to
> > ensure that a single flow gets a unique hash even
> > for strange configurations that transmit the same flow
> > from multiple cpus?
> 
> Once you sort this out, reply with an Acked-by: for me, thanks.

Acked-by: Michael S. Tsirkin <mst@redhat.com>
