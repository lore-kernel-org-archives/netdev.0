From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netxen: fix netxen_nic_poll() logic
Date: Sun, 25 Jan 2015 00:22:15 -0800 (PST)
Message-ID: <20150125.002215.896643903032388131.davem@davemloft.net>
References: <1421909520.3471.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<1421915821.5286.71.camel@marge.simpson.net>
	<1421942178.3471.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: umgwanakikbuti@gmail.com, netdev@vger.kernel.org,
	manish.chopra@qlogic.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbbAYIWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 03:22:16 -0500
In-Reply-To: <1421942178.3471.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Jan 2015 07:56:18 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> NAPI poll logic now enforces that a poller returns exactly the budget
> when it wants to be called again.
> 
> If a driver limits TX completion, it has to return budget as well when
> the limit is hit, not the number of received packets.
> 
> Reported-and-tested-by: Mike Galbraith <umgwanakikbuti@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: d75b1ade567f ("net: less interrupt masking in NAPI")

Applied and queued up for -stable, thanks Eric.
