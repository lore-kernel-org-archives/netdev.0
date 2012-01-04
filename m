From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net_sched: sfq: always randomize hash
 perturbation
Date: Wed, 04 Jan 2012 14:13:07 -0500 (EST)
Message-ID: <20120104.141307.215742763480818454.davem@davemloft.net>
References: <1325694181.2428.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754778Ab2ADTNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 14:13:11 -0500
In-Reply-To: <1325694181.2428.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Jan 2012 17:23:01 +0100

> SFQ q->perturbation is used in sfq_hash() as an input to Jenkins hash.
> 
> We currently randomize this 32bit value only if a perturbation timer is
> setup.
> 
> Its much better to always initialize it to defeat attackers, or else
> they can predict very well what kind of packets they have to forge to
> hit a particular flow.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
