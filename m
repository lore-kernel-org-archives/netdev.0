From: David Miller <davem@davemloft.net>
Subject: Re: Kernel header changes break glibc build
Date: Wed, 06 Dec 2006 16:56:38 -0800 (PST)
Message-ID: <20061206.165638.30168567.davem@davemloft.net>
References: <1165148731.12649.51.camel@pmac.infradead.org>
	<20061204091341.GM8693@postel.suug.ch>
	<200612062033.34754.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, dwmw2@infradead.org, joseph@codesourcery.com,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42050
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S937870AbWLGA41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 19:56:27 -0500
To: stefan@loplof.de
In-Reply-To: <200612062033.34754.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Rompf <stefan@loplof.de>
Date: Wed, 6 Dec 2006 20:32:40 +0100 (MET)

> Am Montag, 4. Dezember 2006 10:13 schrieb Thomas Graf:
> 
> > I do not agree with the change to include if_addr.h in rtnetlink.h.
> > The point is to move bits apart and have multiple small pieces
> > of header files defining a specific rtnetlink family which are a
> > lot easier to maintain for both kernel and userspace than one giant
> > rtnetlink.h for everything.
> 
> According to a user's report, your change also broke compilation of my 
> dhcpclient because it neeeds if_addr.h since 2.6.19. Any suggestion how to 
> make one source code build on 2.6.19 and older headers? I hope you don't want 
> me to check on UTS_RELEASE in a userspace program?

That's enough for me.

Thomas we need to restore things to how they were before.
If that means including if_addr.h from rtnetlink.h so be it.

We can't break shit like this, there are no excuses, especially
now that we properly frob the headers for userspace consumption
in the kernel tree.

Before you hit the reply button, read me again, there are no excuses
for this breakage we've caused.  We must fix it now.

Thanks.
