From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Fix unused variable compile warning
Date: Thu, 1 Oct 2015 09:47:12 -0600
Message-ID: <560D5580.5060608@cumulusnetworks.com>
References: <1443714354-20432-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33020 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223AbbJAPrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 11:47:18 -0400
Received: by pacex6 with SMTP id ex6so78202814pac.0
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 08:47:17 -0700 (PDT)
In-Reply-To: <1443714354-20432-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/1/15 9:45 AM, David Ahern wrote:
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index facba7ed27de..858165f05040 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -1564,4 +1564,4 @@ void fib_select_path(struct net *net, struct fib_result *res,
>   	if (!fl4->saddr)
>   		fl4->saddr = FIB_RES_PREFSRC(net, *res);
>   }
> -EXPORT_SYMBOL(fib_select_path);
> +EXPORT_SYMBOL_GPL(fib_select_path);

grrr.... obviously unrelated. Will resend.
