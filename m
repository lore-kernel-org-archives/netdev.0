From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] bridge: remove extern from function prototypes
Date: Thu, 26 Dec 2013 15:26:18 +0400
Message-ID: <52BC125A.7030707@cogentembedded.com>
References: <52BBCA57.9080706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:36070 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826Ab3LZL0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 06:26:19 -0500
Received: by mail-la0-f45.google.com with SMTP id eh20so3653965lab.18
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 03:26:18 -0800 (PST)
In-Reply-To: <52BBCA57.9080706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 26-12-2013 10:19, Duan Jiong wrote:

> There are a mix of function prototypes with and without extern
> in the kernel sources. Standardize on not using extern for
> function prototypes.

> Function prototypes don't need to be written with extern.
> extern is assumed by the compiler. Its use is as unnecessary as
> using auto to declare automatic/local variables in a block.

> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
>   net/bridge/br_private.h | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 2e77d92..458889e 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -762,7 +762,7 @@ unsigned long br_timer_value(const struct timer_list *timer);
>   
>   /* br.c */
>   #if IS_ENABLED(CONFIG_ATM_LANE)
> -extern int (*br_fdb_test_addr_hook)(struct net_device *dev, unsigned char *addr);
> +int (*br_fdb_test_addr_hook)(struct net_device *dev, unsigned char *addr);

   This is not a function prototype, this is a pointer to function, so
removing *extern* is not right.

>   #endif

WBR, Sergei
