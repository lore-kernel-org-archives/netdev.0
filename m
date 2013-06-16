From: Johannes Stezenbach <js@sig21.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Sun, 16 Jun 2013 19:48:34 +0200
Message-ID: <20130616174834.GA5236@sig21.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
 <20130613222411.GA5396@sig21.net>
 <1371162553.8335.28.camel@jlt4.sipsolutions.net>
 <20130614055346.GB6547@sig21.net>
 <1371320772.8319.2.camel@jlt4.sipsolutions.net>
 <1371327319.14174.1.camel@jlt4.sipsolutions.net>
 <20130616094930.GA5899@sig21.net>
 <1371381472.8546.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:43580 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755371Ab3FPRsk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jun 2013 13:48:40 -0400
Content-Disposition: inline
In-Reply-To: <1371381472.8546.1.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 16, 2013 at 01:17:52PM +0200, Johannes Berg wrote:
> On Sun, 2013-06-16 at 11:49 +0200, Johannes Stezenbach wrote:
> 
> > > I'm assuming you did try the QCA driver and it works?
> > 
> > It worked at some time in the past, but I just tried again
> > and now it doesn't work, it spits a large register dump
> > periodically and then does task:alx_reinit.  I'll try
> > to backtrack to find the working version, but give me
> > some time.
> 
> Ouch. Which tree are you testing there, btw? I found a handful of trees
> on github.

I was using https://github.com/qca/alx.git but after testing
my previous 3.8.13 kernel it seems it doesn't work.  Maybe I
compiled it but never got around to really test it...

The last version which worked was in compat-wireless-3.6.8-1-snpc.tar.bz2
from http://wireless.kernel.org/en/users/Download/stable#compat-wireless_3.6_stable_releases
which I had compiled for linux-3.7.6.


Thanks,
Johannes
