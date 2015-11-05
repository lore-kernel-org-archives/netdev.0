From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix req->saved_syn race
Date: Thu, 05 Nov 2015 14:36:40 -0500 (EST)
Message-ID: <20151105.143640.1782532662947816312.davem@davemloft.net>
References: <1446750433.4184.45.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycai@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbbKETgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 14:36:44 -0500
In-Reply-To: <1446750433.4184.45.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Nov 2015 11:07:13 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> For the reasons explained in commit ce1050089c96 ("tcp/dccp: fix
> ireq->pktopts race"), we need to make sure we do not access
> req->saved_syn unless we own the request sock.
> 
> This fixes races for listeners using TCP_SAVE_SYN option.
> 
> Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
> Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Ying Cai <ycai@google.com>

Applied.
