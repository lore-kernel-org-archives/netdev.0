From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: [PATCH 2/2] myri10ge: use ioremap_wc
Date: Tue, 12 Aug 2008 12:14:39 +0300
Message-ID: <20080812091439.GF4568@deprecation.cyrius.com>
References: <488447E7.2060505@myri.com> <48844831.9040102@myri.com> <20080810112500.GA8060@deprecation.cyrius.com> <489ED823.6000005@myri.com> <20080810123844.GG2486@deprecation.cyrius.com> <20080811090925.GA29143@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brice Goglin <brice@myri.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:3251 "EHLO sorrow.cyrius.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752092AbYHLJQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2008 05:16:34 -0400
Content-Disposition: inline
In-Reply-To: <20080811090925.GA29143@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Russell King - ARM Linux <linux@arm.linux.org.uk> [2008-08-11 10:09]:
> > > > drivers/net/myri10ge/myri10ge.c:3725: error: implicit declaration of function ???ioremap_wc???
> > > 
> > arch/arm/include/asm/io.h doesn't include asm-generic/iomap.h.  When I
> > add this includes, myri10ge compiles.
> > 
> Only that I'm not including asm-generic/iomap.h - we have our own
> iomap implementation, and the generic stuff in there isn't applicable
> to ARM.
> 
> I believe Lennert is sorting out ioremap_wc().

In that case, let's add Lennert to the CC line.
-- 
Martin Michlmayr
http://www.cyrius.com/
