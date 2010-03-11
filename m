From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v6] rps: Receive Packet Steering
Date: Thu, 11 Mar 2010 17:45:18 +0800
Message-ID: <412e6f7f1003110145o48014e57q79e78ac3b8898c1c@mail.gmail.com>
References: <alpine.DEB.1.00.1003102249380.21248@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f182.google.com ([209.85.223.182]:40929 "EHLO
	mail-iw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755101Ab0CKJpi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 04:45:38 -0500
Received: by iwn12 with SMTP id 12so2656341iwn.21
        for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 01:45:38 -0800 (PST)
In-Reply-To: <alpine.DEB.1.00.1003102249380.21248@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 11, 2010 at 3:00 PM, Tom Herbert <therbert@google.com> wrot=
e:
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 93c4e06..472c767 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -581,6 +581,7 @@ static struct sk_buff *__skb_clone(struct sk_buff=
 *n, struct sk_buff *skb)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0C(len);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0C(data_len);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0C(mac_len);
> + =C2=A0 =C2=A0 =C2=A0 C(rxhash);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0n->hdr_len =3D skb->nohdr ? skb_headroom(s=
kb) : skb->hdr_len;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0n->cloned =3D 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0n->nohdr =3D 0;

Why not do the same thing in function __copy_skb_header()?

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
