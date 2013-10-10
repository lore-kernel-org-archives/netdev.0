From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: includes a sock_common in request_sock
Date: Thu, 10 Oct 2013 00:18:14 -0400 (EDT)
Message-ID: <20131010.001814.1654970575830032330.davem@davemloft.net>
References: <1381357289.4971.35.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab3JJESP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 00:18:15 -0400
In-Reply-To: <1381357289.4971.35.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Oct 2013 15:21:29 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP listener refactoring, part 5 :
> 
> We want to be able to insert request sockets (SYN_RECV) into main
> ehash table instead of the per listener hash table to allow RCU
> lookups and remove listener lock contention.
> 
> This patch includes the needed struct sock_common in front
> of struct request_sock
> 
> This means there is no more inet6_request_sock IPv6 specific
> structure.
> 
> Following inet_request_sock fields were renamed as they became
> macros to reference fields from struct sock_common.
> Prefix ir_ was chosen to avoid name collisions.
> 
> loc_port   -> ir_loc_port
> loc_addr   -> ir_loc_addr
> rmt_addr   -> ir_rmt_addr
> rmt_port   -> ir_rmt_port
> iif        -> ir_iif
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
