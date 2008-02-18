From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/8021q/vlan_dev.c - Use print_mac
Date: Mon, 18 Feb 2008 12:55:25 -0800 (PST)
Message-ID: <20080218.125525.192686382.davem@davemloft.net>
References: <20080215.025855.202184003.davem@davemloft.net>
	<1203097370.21308.18.camel@localhost>
	<47B9A20C.10304@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, bruno@thinktube.com, netdev@vger.kernel.org,
	jgarzik@pobox.com, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40600
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756533AbYBRUys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 15:54:48 -0500
In-Reply-To: <47B9A20C.10304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 18 Feb 2008 16:19:40 +0100

> Joe Perches wrote:
> > On Fri, 2008-02-15 at 02:58 -0800, David Miller wrote:
> >> From: Bruno Randolf <bruno@thinktube.com>
> >> Date: Fri, 15 Feb 2008 19:48:05 +0900
> >>> is there any chance to include a macro like this for printing mac
> >> addresses?
> >>> its advantage is that it can be used without the need to declare
> >> buffers for
> >>> print_mac(), for example:
> >> We specifically removed this sort of thing, please don't
> >> add it back.
> 
> Why?

We converted the entire tree over the print_mac(), and since
the MAC_FMT stuff was therefore no longer used we could
remove it.

Some references slipped back in somehow, and thus MAC_FMT
did too.

There is no reason to keep around a global interface for
_one_ user when that user can use the recommended interface
just as equally as the rest of the tree which we converted.

This is a pr_debug() statement we're talking about here.
:-)
