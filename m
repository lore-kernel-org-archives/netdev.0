From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netfilter: nfnetlink_queue: fix compilation
 problem due missing header
Date: Mon, 06 Jan 2014 08:52:41 -0800
Message-ID: <1389027161.12212.181.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389026089-4917-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:32801 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755690AbaAFQwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 11:52:43 -0500
In-Reply-To: <1389026089-4917-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-06 at 17:34 +0100, Pablo Neira Ayuso wrote:
> In 08c0cad ("netfilter: nfnetlink_queue: enable UID/GID socket info
> retrieval"), the header that defines TCP_TIME_WAIT.
> 
> net/netfilter/nfnetlink_queue_core.c: In function 'nfqnl_put_sk_uidgid':
> net/netfilter/nfnetlink_queue_core.c:304:35: error: 'TCP_TIME_WAIT' undeclared (first use in this function)
> net/netfilter/nfnetlink_queue_core.c:304:35: note: each undeclared identifier is reported only once for each function it appears in make[3]: *** [net/netfilter/nfnetlink_queue_core.o] Error 1
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---

Tested-by: Eric Dumazet <edumazet@google.com>

Thanks Pablo !
