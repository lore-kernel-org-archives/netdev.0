From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tso: allow deferring under reordering
 state
Date: Mon, 27 Jul 2015 01:23:36 -0700 (PDT)
Message-ID: <20150727.012336.2241103927980627863.davem@davemloft.net>
References: <1437896724.20182.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752824AbbG0IXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:23:37 -0400
In-Reply-To: <1437896724.20182.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 26 Jul 2015 09:45:24 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> While doing experiments with reordering resilience, we found
> linux senders were not able to send at full speed under reordering,
> because every incoming SACK was releasing one MSS.
> 
> This patch removes the limitation, as we did for CWR state
> in commit a0ea700e409 ("tcp: tso: allow CA_CWR state in
> tcp_tso_should_defer()")
> 
> Neal Cardwell had a concern about limited transmit so
> Yuchung conducted experiments on GFE and found nothing
> worth adding an extra check on fast path :
> 
>   if (icsk->icsk_ca_state == TCP_CA_Disorder &&
>       tcp_sk(sk)->reordering == sysctl_tcp_reordering)
>           goto send_now;
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied.
