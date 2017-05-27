From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH net-next] net: ndisc.c: reduce size of
 __ndisc_fill_addr_option()
Date: Sat, 27 May 2017 18:15:14 +0300
Message-ID: <20170527151514.GA3347@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Linyu.Yuan@alcatel-sbell.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33598 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750885AbdE0PPV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 11:15:21 -0400
Received: by mail-lf0-f68.google.com with SMTP id m18so2992987lfj.0
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 08:15:21 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -148,17 +148,18 @@ void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,

>  	space -= data_len;
> -	if (space > 0)
> -		memset(opt, 0, space);
> +
> +	memset(opt, 0, space);

This can't be right.

And what size are you reducing?
