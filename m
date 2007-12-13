From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.25 splat
Date: Wed, 12 Dec 2007 16:26:13 -0800 (PST)
Message-ID: <20071212.162613.186792052.davem@davemloft.net>
References: <20071212162140.6b81328d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58008
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751835AbXLMA0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 19:26:14 -0500
In-Reply-To: <20071212162140.6b81328d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 12 Dec 2007 16:21:40 -0800

> I don't know why it was doing ipv6 things at all.

When you bring up any interface, with explicit IPV6
addresses or not, the IPV6 stack seeks out local routers
and whatnot using multicast and assigns the interface
a link-local IPV6 address.

So no matter what you're doing IPV6.

I suspect the OOPS you hit might be related to
IPSEC stack work done recently by Herbert Xu who
has been added to the CC:.

I doubt poor Ilpo should be contacted as I doubt his
TCP work is involved :-)
