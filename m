From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Schedule removal of old macros exported to userspace
Date: Sat, 09 Dec 2006 13:45:52 -0800 (PST)
Message-ID: <20061209.134552.71105673.davem@davemloft.net>
References: <20061208.164345.71119524.davem@davemloft.net>
	<20061208.171455.11932070.davem@davemloft.net>
	<20061209103953.GN8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drow@false.org, stefan@loplof.de, dwmw2@infradead.org,
	joseph@codesourcery.com, netdev@vger.kernel.org,
	libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59570
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757769AbWLIVpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 16:45:51 -0500
To: tgraf@suug.ch
In-Reply-To: <20061209103953.GN8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Sat, 9 Dec 2006 11:39:53 +0100

> +What:	Netlink message and attribute parsing macros
> +When:	July 2007
> +Why:	The old interface which often lead to buggy code has been replaced
> +	with a new type safe interface. Parts of this interface, mainly
> +	macros, has been exported to userspace via linux/netlink.h and
> +	linux/rtnetlink.h. Use of this interface is discontinued, all helper
> +	and utility macros will be removed. Userspace applications should use
> +	one of the available libraries.
> +Who:	Thomas Graf <tgraf@suug.ch>

You can't deprecate stuff visible to userspace, sorry Thomas,
we just can't do it.

You can migrate people to "better" interfaces, but you can't
pull the rug out from anyone once things like this are visible
to userspace.  It's permanently there, and we have to live with
that.

Once idea I have is that you could tag these things as
"deprecated" by making them use inline functions or similar
and adding the deprecated GCC attribute to them.  I'd be
very happy to include a patch like that.

This way userland gets the warning and people building it (and
in particular the developer) will see that they have something
to fix up.
