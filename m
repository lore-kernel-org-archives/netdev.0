From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/2] tcp: remove an unnecessary check in
 tcp_tx_timestamp
Date: Wed, 27 Apr 2016 21:35:05 -0700
Message-ID: <1461818105.5535.88.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461814741-848-1-git-send-email-soheil.kdev@gmail.com>
	 <1461814741-848-2-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kafai@fb.com,
	willemb@google.com, edumazet@google.com, ycheng@google.com,
	ncardwell@google.com, Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:32936 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbcD1EfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 00:35:10 -0400
Received: by mail-qk0-f172.google.com with SMTP id n63so27565659qkf.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 21:35:09 -0700 (PDT)
In-Reply-To: <1461814741-848-2-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-27 at 23:39 -0400, Soheil Hassas Yeganeh wrote:
> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> Remove the redundant check for sk->sk_tsflags in tcp_tx_timestamp.
> 
> tcp_tx_timestamp() receives the tsflags as a parameter. As a
> result the "sk->sk_tsflags || tsflags" is redundant, since
> tsflags already includes sk->sk_tsflags plus overrides from
> control messages.
> 
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
