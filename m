From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CONFIG_SMP should be CONFIG_RPS
Date: Tue, 13 Apr 2010 08:59:07 +0200
Message-ID: <1271141947.16881.177.camel@edumazet-laptop>
References: <1271169406-8115-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:53629 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916Ab0DMG7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 02:59:16 -0400
Received: by bwz19 with SMTP id 19so128799bwz.21
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 23:59:13 -0700 (PDT)
In-Reply-To: <1271169406-8115-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 22:36 +0800, Changli Gao a =C3=A9crit :
> CONFIG_SMP should be CONFIG_RPS
>=20
> CONFIG_SMP should be CONFIG_RPS
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  include/linux/netdevice.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index d1a21b5..0efb36e 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1331,7 +1331,7 @@ struct softnet_data {
>  	struct sk_buff		*completion_queue;
> =20
>  	/* Elements below can be accessed between CPUs for RPS */
> -#ifdef CONFIG_SMP
> +#ifdef CONFIG_RPS
>  	struct call_single_data	csd ____cacheline_aligned_in_smp;
>  #endif
>  	struct sk_buff_head	input_pkt_queue;

Thanks Changli, this is part of RFS patches :)


