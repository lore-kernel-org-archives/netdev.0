From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Remove fib_hash.
Date: Wed, 02 Feb 2011 13:51:05 -0800 (PST)
Message-ID: <20110202.135105.71107300.davem@davemloft.net>
References: <1296607693.2607.7.camel@edumazet-laptop>
	<20110201.181542.193701016.davem@davemloft.net>
	<20110202082921.7eee82e0@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54350
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754043Ab1BBVu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 16:50:29 -0500
In-Reply-To: <20110202082921.7eee82e0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 2 Feb 2011 08:29:21 -0800

> For the case of small devices, what about keeping fib_hash as option
> under CONFIG_EMBEDDED. And remove all the magic resizing of hash table.
> Get back to something with really small size.

That's still going to be ~20,000 lines of code kept in the tree
duplicating functionality.

Sorry, no.
