From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Add NAPI support to ll_temac driver
Date: Tue, 19 Apr 2011 15:13:32 +0200
Message-ID: <1303218812.3480.160.camel@edumazet-laptop>
References: <4DAD5753.4040108@monstr.eu>
	 <1303209787.3480.9.camel@edumazet-laptop>
	 <1303215925.3464.54.camel@localhost>  <4DAD84B1.9020405@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45128 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754899Ab1DSNNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 09:13:37 -0400
Received: by wya21 with SMTP id 21so4791470wya.19
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 06:13:36 -0700 (PDT)
In-Reply-To: <4DAD84B1.9020405@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 avril 2011 =C3=A0 14:48 +0200, Michal Simek a =C3=A9crit :

> Can you please be more specific about passing the paged buffers into =
GRO?
> Or point me to any documentation or code which can help me to underst=
and what=20
> that means.

Search for napi_get_frags() :

drivers/net/mlx4/en_rx.c:597:					struct sk_buff *gro_skb =3D napi_get_=
frags(&cq->napi);
drivers/net/cxgb3/sge.c:2091:		skb =3D napi_get_frags(&qs->napi);
drivers/net/cxgb4/sge.c:1517:	skb =3D napi_get_frags(&rxq->rspq.napi);
drivers/net/qlge/qlge_main.c:1484:	skb =3D napi_get_frags(napi);
drivers/net/sfc/rx.c:471:		skb =3D napi_get_frags(napi);
drivers/net/benet/be_main.c:1039:	skb =3D napi_get_frags(&eq_obj->napi)=
;
drivers/net/cxgb4vf/sge.c:1479:	skb =3D napi_get_frags(&rxq->rspq.napi)=
;



