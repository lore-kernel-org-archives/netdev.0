From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] virtio-net: fix a race on 32bit arches
Date: Wed, 06 Jun 2012 22:25:57 +0200
Message-ID: <1339014357.26966.72.camel@edumazet-glaptop>
References: <1338971724.2760.3913.camel@edumazet-glaptop>
	<1338972341.2760.3944.camel@edumazet-glaptop>
	<20120606111357.GA15070@redhat.com>
	<1338988210.2760.4485.camel@edumazet-glaptop>
	<20120606144941.GA17092@redhat.com>
	<20120606081432.6b602065@nehalam.linuxnetplumber.net>
	<20120606185107.GA20503@redhat.com>
	<1339012441.26966.48.camel@edumazet-glaptop>
	<20120606195814.GA20677@redhat.com>
	<1339013289.26966.62.camel@edumazet-glaptop>
	<1339013979.2836.52.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1339013979.2836.52.camel@bwh-desktop.uk.solarflarecom.com>
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

On Wed, 2012-06-06 at 21:19 +0100, Ben Hutchings wrote:
> On Wed, 2012-06-06 at 22:08 +0200, Eric Dumazet wrote:
> > On Wed, 2012-06-06 at 22:58 +0300, Michael S. Tsirkin wrote:
> > 
> > > Absolutely, I am talking about virtio here.  I'm not kicking
> > > u64_stats_sync idea I am just saying that simple locking
> > > would work for virtio and might be better as it
> > > gives us a way to get counters atomically.
> > 
> > Which lock do you own in the RX path ?
> > 
> > You'll have to add a lock in fast path. This sounds really a bad choice
> > to me.
> 
> You have the NAPI 'lock', so when gathering stats you can synchronise
> using napi_disable() ;-)

Nice, this adds one new bug in network stack.

Really guys, can we stop this thread, please ?
