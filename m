From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/4] [RFC] virtio-net: Improve small packet performance
Date: Thu, 5 May 2011 18:42:45 +0300
Message-ID: <20110505154245.GB2168@redhat.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com>
 <20110504144622.GA15823@redhat.com>
 <OFAEA8C363.C13C507B-ON65257886.0051F71F-65257886.0052217F@in.ibm.com>
 <20110504212359.GA21446@redhat.com>
 <OF2E0182A1.3818A07E-ON65257887.00225EE8-65257887.002C000C@in.ibm.com>
 <20110505090439.GD17647@redhat.com>
 <OFB1ACC9EB.4567C1B1-ON65257887.0050044B-65257887.0054A5CE@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OFB1ACC9EB.4567C1B1-ON65257887.0050044B-65257887.0054A5CE@in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2011 at 08:57:13PM +0530, Krishna Kumar2 wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 05/05/2011 02:34:39 PM:
> 
> > > Do I need to apply all the patches and simply test?
> > >
> > > Thanks,
> > >
> > > - KK
> >
> > Exactly. You can also try to tune the threshold
> > for interrupts as well.
> 
> I haven't tuned the threshhold, it is left it at 3/4. I ran
> the new qemu/vhost/guest, and the results for 1K, 2K and 16K
> are below. Note this is a different kernel version from my
> earlier test results. So, f.e., BW1 represents 2.6.39-rc2,
> the original kernel; while BW2 represents 2.6.37-rc5 (MST's
> kernel). This also isn't with the fixes you have sent just
> now. I will get a run with that either late tonight or
> tomorrow.

One thing I'd suggest is merging v2.6.39-rc6 into that tree.
rc2 is still pretty early, reason I use it is because that is
what net-next is.

-- 
MST
