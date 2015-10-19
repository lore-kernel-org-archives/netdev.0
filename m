From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: do not set queue_mapping on SYNACK
Date: Sun, 18 Oct 2015 22:26:15 -0700 (PDT)
Message-ID: <20151018.222615.1410928614255717702.davem@davemloft.net>
References: <1445025601.30896.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbbJSFJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 01:09:58 -0400
In-Reply-To: <1445025601.30896.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Oct 2015 13:00:01 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> At the time of commit fff326990789 ("tcp: reflect SYN queue_mapping into
> SYNACK packets") we had little ways to cope with SYN floods.
> 
> We no longer need to reflect incoming skb queue mappings, and instead
> can pick a TX queue based on cpu cooking the SYNACK, with normal XPS
> affinities.
> 
> Note that all SYNACK retransmits were picking TX queue 0, this no longer
> is a win given that SYNACK rtx are now distributed on all cpus.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
