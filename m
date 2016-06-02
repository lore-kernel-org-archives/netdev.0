From: David Miller <davem@davemloft.net>
Subject: Re: Possible problem with e6afc8ac ("udp: remove headers from UDP
 packets before queueing")
Date: Thu, 02 Jun 2016 18:31:51 -0400 (EDT)
Message-ID: <20160602.183151.2030076167275348260.davem@davemloft.net>
References: <0b1fde4f-57ef-8c5e-147f-10c4a51fb2b0@tycho.nsa.gov>
	<CAHC9VhQAiTRWMN-vNDXgAni2MhsyEYP8f2mZDY63xrx=5SxenQ@mail.gmail.com>
	<1464904363.5939.185.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul@paul-moore.com, samanthakumar@google.com,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, sds@tycho.nsa.gov
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080AbcFBWbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 18:31:52 -0400
In-Reply-To: <1464904363.5939.185.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Jun 2016 14:52:43 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Paul Moore tracked a regression caused by a recent commit, which
> mistakenly assumed that sk_filter() could be avoided if socket
> had no current BPF filter.
> 
> The intent was to avoid udp_lib_checksum_complete() overhead.
> 
> But sk_filter() also checks skb_pfmemalloc() and
> security_sock_rcv_skb(), so better call it.
> 
> Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Paul Moore <paul@paul-moore.com>
> Tested-by: Paul Moore <paul@paul-moore.com>
> Tested-by: Stephen Smalley <sds@tycho.nsa.gov>
> Cc: samanthakumar <samanthakumar@google.com>

Applied, thanks Eric.
