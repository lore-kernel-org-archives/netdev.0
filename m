From: Johannes Stezenbach <js@sig21.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Sun, 16 Jun 2013 20:06:13 +0200
Message-ID: <20130616180613.GA5361@sig21.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
 <20130613222411.GA5396@sig21.net>
 <1371162553.8335.28.camel@jlt4.sipsolutions.net>
 <20130614055346.GB6547@sig21.net>
 <1371320772.8319.2.camel@jlt4.sipsolutions.net>
 <1371327319.14174.1.camel@jlt4.sipsolutions.net>
 <20130616094930.GA5899@sig21.net>
 <1371381472.8546.1.camel@jlt4.sipsolutions.net>
 <20130616174834.GA5236@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:43631 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752242Ab3FPSGR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jun 2013 14:06:17 -0400
Content-Disposition: inline
In-Reply-To: <20130616174834.GA5236@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 16, 2013 at 07:48:34PM +0200, Johannes Stezenbach wrote:
> On Sun, Jun 16, 2013 at 01:17:52PM +0200, Johannes Berg wrote:
> > On Sun, 2013-06-16 at 11:49 +0200, Johannes Stezenbach wrote:
> > 
> > > > I'm assuming you did try the QCA driver and it works?
> > > 
> > > It worked at some time in the past, but I just tried again
> > > and now it doesn't work, it spits a large register dump
> > > periodically and then does task:alx_reinit.  I'll try
> > > to backtrack to find the working version, but give me
> > > some time.
> > 
> > Ouch. Which tree are you testing there, btw? I found a handful of trees
> > on github.
> 
> I was using https://github.com/qca/alx.git but after testing
> my previous 3.8.13 kernel it seems it doesn't work.  Maybe I
> compiled it but never got around to really test it...
> 
> The last version which worked was in compat-wireless-3.6.8-1-snpc.tar.bz2
> from http://wireless.kernel.org/en/users/Download/stable#compat-wireless_3.6_stable_releases
> which I had compiled for linux-3.7.6.

FWIW, these are the messages printed when loading it:

[   61.972473] Compat-wireless backport release: compat-wireless-v3.6.8-1-snpc
[   61.972479] Backport based on linux-stable.git v3.6.8
[   61.972481] compat.git: linux-stable.git
[   61.976397] Qualcomm Atheros(R) AR813x/AR815x/AR816x PCI-E Ethernet Network Driver
[   61.976460] alx 0000:03:00.0: DMA to 64-BIT addresses
[   61.976667] alx 0000:03:00.0: (unregistered net_device): HW Flags = 0x415
[   61.977192] alx 0000:03:00.0: (unregistered net_device): reset PHY, pws = 1, az = 0, ptp = 0
[   61.978402] alx 0000:03:00.0: (unregistered net_device): speed = 0x2f, autoneg = 1
[   61.979494] alx 0000:03:00.0: irq 45 for MSI/MSI-X
[   61.979880] alx: Atheros Gigabit Network Connection


Johannes
