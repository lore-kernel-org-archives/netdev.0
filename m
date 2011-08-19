From: David Miller <davem@davemloft.net>
Subject: Re: 6LoWPAN basic support
Date: Thu, 18 Aug 2011 22:07:03 -0700 (PDT)
Message-ID: <20110818.220703.2167958273578893796.davem@davemloft.net>
References: <CAJmB2rDEyzaAb4zsuhbr_XY=4BFzHv9zwYtA5BHQzO4R8tuZ2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com, slapin@ossfans.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630Ab1HSFHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 01:07:13 -0400
In-Reply-To: <CAJmB2rDEyzaAb4zsuhbr_XY=4BFzHv9zwYtA5BHQzO4R8tuZ2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Tue, 16 Aug 2011 22:38:08 +0400

> Hello all,
> 
> the following patch adds basic support for 6LoWPAN techology.
> This is an implementation of ipv6 header compression according
> RFC4944 which allows transmit data over IEEE802.15.4 networks
> using IPv6 stack.
> 
> Currently it's only basic support which works with packet size less
> than 128 bytes. In this patch 6LoWPAN is implemented as midle-layer
> between IEEE802.15.4 and IPv6 stacks.
> 
> Features supported:
> 1. TCP header compression;
> 2. Neighbour discovery.
> 
> The following features are going to be implemented:
> 1. Fragmentation (the MTU of IEEE802.15.4 is 128 bytes);
> 2. UDP and NextHeader compression;
> 3. Context-based compression.

Would be nice to see some review from Dmitry and Sergey since they
are the listed maintainers of 802.15.4
