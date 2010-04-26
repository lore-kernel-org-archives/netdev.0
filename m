From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RPS and forwarding
Date: Mon, 26 Apr 2010 09:38:54 +0200
Message-ID: <1272267534.2346.7.camel@edumazet-laptop>
References: <z2w65634d661004252144z1bf72880wdf7a0143b8490ddf@mail.gmail.com>
	 <20100426045316.GA21810@gondor.apana.org.au>
	 <r2n65634d661004252200x4e7a49f1h181cdd69b3e4ebc0@mail.gmail.com>
	 <20100425.232857.145290769.davem@davemloft.net>
	 <20100426063136.GA22401@gondor.apana.org.au>
	 <1272266716.2346.5.camel@edumazet-laptop>
	 <20100426073017.GA22803@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:54360 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717Ab0DZHjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 03:39:00 -0400
Received: by bwz19 with SMTP id 19so192137bwz.21
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 00:38:57 -0700 (PDT)
In-Reply-To: <20100426073017.GA22803@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 avril 2010 =C3=A0 15:30 +0800, Herbert Xu a =C3=A9crit :
> On Mon, Apr 26, 2010 at 09:25:16AM +0200, Eric Dumazet wrote:
> >
> > RFS is already working like that, if RPS is not used in conjonction=
=2E
> >=20
> > Forwarded traffic will see a non tagged rfs flow entry, so this skb=
 will
> > be processed by this cpu, not a remote one.
> >=20
> > Currently, only an application can set a RFS flow entry.
>=20
> I was referring to the case when a forwarded flow gets hashed to
> the same index as a local flow.

Ah OK, with same rxhash I guess ?

(we could store rxhash next to cpu in struct rps_dev_flow, or 16bit par=
t
of it in the existing padding)



