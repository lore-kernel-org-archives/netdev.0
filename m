From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] netpoll: Use 'bool' for netpoll_rx() return type.
Date: Thu, 6 May 2010 16:27:44 +0800
Message-ID: <g2k412e6f7f1005060127g11f7b1e6vddd448178e1ddff9@mail.gmail.com>
References: <20100506.012051.149835101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:43500 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755371Ab0EFI2E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 04:28:04 -0400
Received: by pxi5 with SMTP id 5so1982730pxi.19
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 01:28:04 -0700 (PDT)
In-Reply-To: <20100506.012051.149835101.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 6, 2010 at 4:20 PM, David Miller <davem@davemloft.net> wrot=
e:
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>
> I noticed this while validating and auditing Eric Dumazet's vnet
> fix... =C2=A0applied to net-next-2.6
>
> =C2=A0include/linux/netpoll.h | =C2=A0 =C2=A08 ++++----
> =C2=A01 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
> index 017e604..3688c83 100644
> --- a/include/linux/netpoll.h
> +++ b/include/linux/netpoll.h
> @@ -55,19 +55,19 @@ void netpoll_send_skb(struct netpoll *np, struct =
sk_buff *skb);
>
>
> =C2=A0#ifdef CONFIG_NETPOLL
> -static inline int netpoll_rx(struct sk_buff *skb)
> +static inline bool netpoll_rx(struct sk_buff *skb)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct netpoll_info *npinfo =3D skb->dev->=
npinfo;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
> - =C2=A0 =C2=A0 =C2=A0 int ret =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 int ret =3D false;
>

bool ret =3D false.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
