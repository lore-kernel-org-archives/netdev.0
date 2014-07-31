From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: addrconf: fix mcast route for GRE
 devices
Date: Thu, 31 Jul 2014 12:06:04 -0700 (PDT)
Message-ID: <20140731.120604.1650999676882971183.davem@davemloft.net>
References: <20140730163140.GL801478@jupiter.n2.diac24.net>
	<1406739141.6757.22.camel@localhost>
	<20140730173544.GM801478@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbaGaTGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 15:06:05 -0400
In-Reply-To: <20140730173544.GM801478@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Wed, 30 Jul 2014 19:35:44 +0200

> This is RT6_TABLE_LOCAL.  Most people aren't even aware it exists.  And
> even though I can't find a reference for it, my memory tells me that
> "table local" is supposed to be under the kernel's authority.

The origin of local routing tables (both in ipv4 and ipv6) has more to
do with internal implementation issues rather than issues pertaining
to how the user should or should not manipulate routes.

It's basically an optimization for local packet delivery, since the
local routing tables get consulted first.  Secondly, separation of
local and non-local routes into different tables theoretically makes
those tables less dense and thus resulting in faster lookups.
