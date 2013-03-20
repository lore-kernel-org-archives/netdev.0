From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/3 net-next] tcp: refactor CA_Loss state processing
Date: Wed, 20 Mar 2013 16:56:57 -0700
Message-ID: <1363823817.3333.32.camel@edumazet-glaptop>
References: <1363822380-16687-1-git-send-email-ycheng@google.com>
	 <1363822380-16687-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com, ilpo.jarvinen@cs.helsinki.fi,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:56025 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676Ab3CTX5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 19:57:00 -0400
Received: by mail-da0-f52.google.com with SMTP id f10so1285698dak.11
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 16:57:00 -0700 (PDT)
In-Reply-To: <1363822380-16687-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-20 at 16:32 -0700, Yuchung Cheng wrote:
> Consolidate all of TCP CA_Loss state processing in
> tcp_fastretrans_alert() into a new function called tcp_process_loss().
> This is to prepare the new F-RTO implementation in the next patch.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> ---
>  net/ipv4/tcp_input.c | 42 ++++++++++++++++++++++++++----------------
>  1 file changed, 26 insertions(+), 16 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
