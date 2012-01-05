From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: red: split red_parms into parms
 and vars
Date: Thu, 05 Jan 2012 14:08:57 -0500 (EST)
Message-ID: <20120105.140857.1619240536719070061.davem@davemloft.net>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dave.taht@gmail.com, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088Ab2AETJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 14:09:00 -0500
In-Reply-To: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Jan 2012 13:25:16 +0100

> This patch splits the red_parms structure into two components.
> 
> One holding the RED 'constant' parameters, and one containing the
> variables.
> 
> This permits a size reduction of GRED qdisc, and is a preliminary step
> to add an optional RED unit to SFQ. 
> 
> SFQRED will have a single red_parms structure shared by all flows, and a
> private red_vars per flow.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
