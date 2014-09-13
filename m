From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] netdevice: Support DSA tagging when DSA is built as a
 module
Date: Sat, 13 Sep 2014 03:06:02 -0700
Message-ID: <5414170A.4080907@gmail.com>
References: <20140913015950.26705.51106.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kernel@wantstofly.org
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:54214 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbaIMDGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 23:06:06 -0400
Received: by mail-oi0-f47.google.com with SMTP id a141so1107054oig.34
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 20:06:05 -0700 (PDT)
In-Reply-To: <20140913015950.26705.51106.stgit@ahduyck-workstation.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/09/2014 18:59, Alexander Duyck a =C3=A9crit :
> This change corrects an error seen when DSA tagging is built as a mod=
ule.
> Without this change it is not possible to get XDSA tagged frames as t=
he
> test for tagging is stripped by the #ifdef check.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>   include/linux/netdevice.h |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index ba72f6b..c8f3806 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1789,7 +1789,7 @@ void dev_net_set(struct net_device *dev, struct=
 net *net)
>
>   static inline bool netdev_uses_dsa(struct net_device *dev)
>   {
> -#ifdef CONFIG_NET_DSA
> +#if IS_ENABLED(CONFIG_NET_DSA)
>   	if (dev->dsa_ptr !=3D NULL)
>   		return dsa_uses_tagged_protocol(dev->dsa_ptr);
>   #endif
>
