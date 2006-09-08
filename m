From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH,RFC] Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Fri, 8 Sep 2006 22:23:36 +0200
Message-ID: <20060908202336.GA23545@electric-eye.fr.zoreil.com>
References: <20060728101109.GA25854@xi.wantstofly.org> <20060818212852.GA5379@xi.wantstofly.org> <20060820213558.GA13188@electric-eye.fr.zoreil.com> <20060904220741.GE3782@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tbm@cyrius.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:63362 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751206AbWIHUYd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 16:24:33 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20060904220741.GE3782@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek <buytenh@wantstofly.org> :
[...]
> I suspect it's a chip bug.  I rechecked with I/O space, and that works
> okay, so this artifact (bug) only manifests itself when you do the upper
> write in MMIO space.
>
> Are there any plans to switch r8169 to the iomap API?  Would you take
> a patch if I'd write one?

Given the current state of the r8169 driver, I do not see a lot of
benefit from the iomap() API in itself.

It could make the switch to I/O read/write easier for strange bugs
like your but I have an epidermic defiance against I/O ops (much too 
synchronizing for me: people forget that MMIO will post). I may
change my mind if bugs start poping up like mushrooms but we are
hopefully not there yet.

An ordered write with a big sign in front of it to comment the issue
is good enough for me.

Don't hesitate to protest if you think that I need a clue.

-- 
Ueimor
