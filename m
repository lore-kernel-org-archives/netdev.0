From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/1] l2tp: Use existing macros instead of literal
 number
Date: Fri, 19 Aug 2016 14:32:02 -0700 (PDT)
Message-ID: <20160819.143202.85723375204268037.davem@davemloft.net>
References: <1471503919-30889-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55349 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755372AbcHSVja (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 17:39:30 -0400
In-Reply-To: <1471503919-30889-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Thu, 18 Aug 2016 15:05:19 +0800

> @@ -138,6 +138,8 @@ static const struct ppp_channel_ops pppol2tp_chan_ops = {
>  
>  static const struct proto_ops pppol2tp_ops;
>  
> +static const unsigned char fixed_ppphdr[2] = {PPP_ALLSTATIONS, PPP_UI};
> +
>  /* Helpers to obtain tunnel/session contexts from sockets.
>   */
>  static inline struct l2tp_session *pppol2tp_sock_to_session(struct sock *sk)

Same problem as the pptp patch, I'm not applying this.
