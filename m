From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCHv3] printk: add %pM format specifier for MAC
 addresses
Date: Mon, 27 Oct 2008 17:22:39 -0700
Message-ID: <1225153359.5269.112.camel@localhost>
References: <1225137542.5396.10.camel@brick>
	 <20081027.154736.178482850.davem@davemloft.net>
	 <1225149254.6339.4.camel@brick>
	 <20081027.165556.30975206.davem@davemloft.net>
	 <1225152339.5526.1.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	anders@anduras.de, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1660 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbYJ1AXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 20:23:23 -0400
In-Reply-To: <1225152339.5526.1.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-10-27 at 17:05 -0700, Harvey Harrison wrote:
> On Mon, 2008-10-27 at 16:55 -0700, David Miller wrote:
> > I'm ok with the '#' modifier but remind me again what's wrong with
> > using plain %p4 and %p6?
> Nothing at all, just wanted to know what color bikeshed you wanted.
> I'll go with %p4 %p6.

Just an FYI for v6 addresses:

There are a few uses of ipv6 address as "%08X%08X%08X%08X" 
Pavel Emelyanov tried to isolate them with a suggested patch:

http://www.mail-archive.com/netdev@vger.kernel.org/msg51655.html

These addresses are not shown in network order, but are
printed backwards in host order. Oops.  Apparently it's
too late to fix them.

