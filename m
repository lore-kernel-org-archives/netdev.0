From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 23 Feb 2012 19:49:25 +0100
Message-ID: <1330022965.15610.32.camel@edumazet-laptop>
References: <20120222055139.GB8026@google.com>
	 <1329896195.18384.83.camel@edumazet-laptop>
	 <CADVnQyk+ujAXPh1=59TB-Pb6ZcQX8NWCN5pWoNvXXLBnr6qOhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:52893 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632Ab2BWStc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 13:49:32 -0500
Received: by wics10 with SMTP id s10so964579wic.19
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 10:49:31 -0800 (PST)
In-Reply-To: <CADVnQyk+ujAXPh1=59TB-Pb6ZcQX8NWCN5pWoNvXXLBnr6qOhg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 f=C3=A9vrier 2012 =C3=A0 13:39 -0500, Neal Cardwell a =C3=A9=
crit :

>   u32 incr =3D max(skb->len, 2U * tp->advmss);
>=20
> Or do you think we'd want:
>=20
>   u32 incr =3D 2U * max(skb->len, tp->advmss);
>=20


or :

incr =3D 2 * skb->len;
