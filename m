From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Schedule removal of old macros exported to userspace
Date: Sat, 09 Dec 2006 13:49:28 -0800 (PST)
Message-ID: <20061209.134928.78719042.davem@davemloft.net>
References: <20061209103953.GN8693@postel.suug.ch>
	<200612091249.39302.stefan@loplof.de>
	<20061209125533.GO8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefan@loplof.de, drow@false.org, dwmw2@infradead.org,
	joseph@codesourcery.com, netdev@vger.kernel.org,
	libc-alpha@sourceware.org, akpm@osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59584
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758366AbWLIVt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 16:49:27 -0500
To: tgraf@suug.ch
In-Reply-To: <20061209125533.GO8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Sat, 9 Dec 2006 13:55:33 +0100

> The point is to stop new applications from using the interface which has
> resulted in buggy code in the past.

You don't get people to use new interface by breaking the
build on them in userspace.

You get them to do it by making suggestions and informing them, not
by forcing them.

That's why 1) you can't get rid of these macros, ever, but 2) you can
warn them by using inline functions and depcrecated attribute tags.
