From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: fix match_fanout_group()
Date: Mon, 12 Oct 2015 19:43:02 -0700 (PDT)
Message-ID: <20151012.194302.348030712388370670.davem@davemloft.net>
References: <1444415372.27760.74.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric@regit.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932122AbbJMC1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 22:27:03 -0400
In-Reply-To: <1444415372.27760.74.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Oct 2015 11:29:32 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Recent TCP listener patches exposed a prior af_packet bug :
> match_fanout_group() blindly assumes it is always safe
> to cast sk to a packet socket to compare fanout with af_packet_priv
> 
> But SYNACK packets can be sent while attached to request_sock, which
> are smaller than a "struct sock".
> 
> We can read non existent memory and crash.
> 
> Fixes: c0de08d04215 ("af_packet: don't emit packet on orig fanout group")
> Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
