From: David Miller <davem@davemloft.net>
Subject: Re: RCU lock bug in 3.0.21 (bisected to: 682cb56a, fix NULL
 dereferences in check_peer_redir)
Date: Mon, 26 Mar 2012 19:11:47 -0400 (EDT)
Message-ID: <20120326.191147.469484932758702483.davem@davemloft.net>
References: <20120326.174945.1186427809261872546.davem@davemloft.net>
	<4F70E560.3020102@candelatech.com>
	<4F70F688.6050108@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	gregkh@linuxfoundation.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35717 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934Ab2CZXLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 19:11:54 -0400
In-Reply-To: <4F70F688.6050108@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Mon, 26 Mar 2012 16:06:48 -0700

> That said, I don't see any issues with the inet6_dump_fib
> method, so maybe my debug attempt is not valid..or lockdep debugging
> has issues of some sort.

This is exactly where Eric and myself hit a dead-end on Dave
Jones's reports.
