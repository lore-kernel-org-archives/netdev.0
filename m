From: David Miller <davem@davemloft.net>
Subject: Re: increase the number of routing tables
Date: Mon, 30 Jan 2012 12:36:32 -0500 (EST)
Message-ID: <20120130.123632.387135158499048554.davem@davemloft.net>
References: <4F24B2E9.3010600@candelatech.com>
	<20120129.160152.1463516627658543873.davem@davemloft.net>
	<4F26D2C1.7030108@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, simonchennj@gmail.com,
	netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742Ab2A3Rgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 12:36:36 -0500
In-Reply-To: <4F26D2C1.7030108@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Mon, 30 Jan 2012 09:26:25 -0800

> Well, that sounds like a reason to keep the routing cache around,
> even if it isn't used by default, perhaps.

The routing cache is fundamentally DoS'able and this problem
is independent of the routing rule issues being discussed here.

Therefore it will be removed, and if people want routing rule
performance to be better in the regime they better start
thinking about how to do that (without reintroducing the
DoS issue) now.
