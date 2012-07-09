From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] tcp: limit data skbs in qdisc layer
Date: Mon, 09 Jul 2012 00:08:34 -0700 (PDT)
Message-ID: <20120709.000834.1182150057463599677.davem@davemloft.net>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	<1340945457.29822.7.camel@edumazet-glaptop>
	<1341396687.2583.1757.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, dave.taht@gmail.com, netdev@vger.kernel.org,
	codel@lists.bufferbloat.net, therbert@google.com,
	mattmathis@google.com, nanditad@google.com, ncardwell@google.com,
	andrewmcgr@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53526 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571Ab2GIHIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 03:08:35 -0400
In-Reply-To: <1341396687.2583.1757.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Jul 2012 12:11:27 +0200

> sk->sk_wmem_alloc not allowed to grow above a given limit,
> allowing no more than ~4 segments [1] per tcp socket in qdisc layer at a
> given time. (if TSO is enabled, then a single TSO packet hits the limit)

I'm suspicious and anticipate that 10G will need more queueing than
you are able to get away with tg3 at 1G speeds.  But it is an exciting
idea nonetheless :-)
