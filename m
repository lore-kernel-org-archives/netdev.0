From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 02/16] net: change netdev->features to u32
Date: Sun, 23 Jan 2011 11:35:13 +0100
Message-ID: <1295778913.17333.28.camel@edumazet-laptop>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
	 <d9fe088556152bd3b43390e0fb5ea20d83aef233.1295734271.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37658 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379Ab1AWKfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jan 2011 05:35:20 -0500
Received: by wwa36 with SMTP id 36so3367127wwa.1
        for <netdev@vger.kernel.org>; Sun, 23 Jan 2011 02:35:18 -0800 (PST)
In-Reply-To: <d9fe088556152bd3b43390e0fb5ea20d83aef233.1295734271.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 22 janvier 2011 =C3=A0 23:14 +0100, Micha=C5=82 Miros=C5=82aw=
 a =C3=A9crit :
> Quoting Ben Hutchings: we presumably won't be defining features that
> can only be enabled on 64-bit architectures.
>=20
> Occurences found by `grep -r` on net/, drivers/net, include/
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---

=2E..

>  	/* Unset features, set them as we chew on the arg. */
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 371fa88..c73d63d 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -894,7 +894,7 @@ struct net_device {
>  	struct list_head	unreg_list;
> =20
>  	/* Net device features */
> -	unsigned long		features;
> +	u32			features;
>  #define NETIF_F_SG		1	/* Scatter/gather IO. */
>  #define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
>  #define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopac=
k. */
> @@ -1150,7 +1150,7 @@ struct net_device {
>  	const struct rtnl_link_ops *rtnl_link_ops;
> =20
>  	/* VLAN feature mask */
> -	unsigned long vlan_features;
> +	u32 vlan_features;
> =20
>  	/* for setting kernel sock attribute on TCP connection setup */


Could you move "vlan_features" right after "features", so that no holes
are there on 64bit arches ?


