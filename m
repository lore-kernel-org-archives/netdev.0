From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [GIT]: Networking
Date: Wed, 6 Aug 2008 10:21:55 +0200
Message-ID: <200808061021.56150.IvDoorn@gmail.com>
References: <20080805.190020.244441681.davem@davemloft.net> <alpine.LFD.1.10.0808051937410.15995@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:45777 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755787AbYHFH4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 03:56:53 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1078774nfc.21
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 00:56:51 -0700 (PDT)
In-Reply-To: <alpine.LFD.1.10.0808051937410.15995@nehalem.linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 August 2008, Linus Torvalds wrote:
> 
> On Tue, 5 Aug 2008, David Miller wrote:
> > 
> > There was going to be the addition of the ath9k wireless driver but
> > there was some fallout that is being worked on right now (linux/list.h
> > changes needed lkml review, ath9k driver triggered some gcc aborts,
> > all kinds of fun stuff :-) so hopefully it will make it in the next
> > pass.  I tried to wait an extra day for it to be resolved, but that
> > was optimistic.
> 
> Talking about wireless driver updates - has anybody looked at the RaLink 
> wireless driver?  It's in the newer EeePC's (901 and 1000), and it 
> actually has a driver from the company which the comments make clear is 
> GPLv2 too, no apparent oddness or anything:
> 
> 	http://www.ralinktech.com.tw/data/drivers/2008_0708_RT2860_Linux_STA_v1.7.0.0.tar.bz2
> 
> which admittedly apparently has some trivial problems (with a trivial 
> patch as seen at
> 
> 	http://fedoraforum.org/forum/showthread.php?t=195429
> 
> I'd love to have that one working, since I have the hardware, and it's 
> actually reasonable (much more so than the original EeePC, in fact). What 
> channels should I go through? Is anybody working on integrating it 
> already?

Like the earlier rt2x00 drivers I am rewriting the driver as released by Ralink and
have put it in the rt2x00lib/mac80211 framework. Most of the code is currently done, and the
last part should be done this week. After that it is a matter of testing and comparing
register values with the Ralink driver for the last tweaks.

I doubt the driver will be ready/stable for 2.6.28, but it should be ready for 2.6.29.

Ivo


