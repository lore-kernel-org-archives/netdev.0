From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [NETLINK]: Schedule removal of old macros exported to userspace
Date: Sun, 10 Dec 2006 00:28:05 +0100
Message-ID: <20061209232805.GP8693@postel.suug.ch>
References: <20061208.164345.71119524.davem@davemloft.net> <20061208.171455.11932070.davem@davemloft.net> <20061209103953.GN8693@postel.suug.ch> <20061209.134552.71105673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: drow@false.org, stefan@loplof.de, dwmw2@infradead.org,
	joseph@codesourcery.com, netdev@vger.kernel.org,
	libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:39094 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759776AbWLIX1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Dec 2006 18:27:45 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061209.134552.71105673.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2006-12-09 13:45
> You can't deprecate stuff visible to userspace, sorry Thomas,
> we just can't do it.

It has been done before but I don't want to drag this on
any further. I did what I found to be right and obviously
I've hit a wall.

> Once idea I have is that you could tag these things as
> "deprecated" by making them use inline functions or similar
> and adding the deprecated GCC attribute to them.  I'd be
> very happy to include a patch like that.
> 
> This way userland gets the warning and people building it (and
> in particular the developer) will see that they have something
> to fix up.

I'm not going to spend any time on patching broken interfaces. I've
provided an alternative for those able and willing to switch, that's
as far as I'll go.

I had a short glance at dhcpclient's netlink code and found half
a dozen bugs within five minutes all caused by cut and pasting
sniplets from other netlink code. It is my opinion that people
will continue to drag along bugs this way unless the interface is
removed. I never believed in providing backward compatibility to
broken code.
