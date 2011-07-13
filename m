From: Roland Dreier <roland@purestorage.com>
Subject: Re: [PATCH 2/2] ipv4: Use universal hash for ARP.
Date: Wed, 13 Jul 2011 10:59:08 -0700
Message-ID: <CAL1RGDWXqnL4zzcfV_kj=R2P148JcVB2X2QUV90__+e5zUH-cQ@mail.gmail.com>
References: <20110711.014845.1009062692530385177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johnwheffner@gmail.com, mj@ucw.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog101.obsmtp.com ([74.125.245.70]:40144 "HELO
	na3sys010aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754661Ab1GMR73 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 13:59:29 -0400
Received: by ywm21 with SMTP id 21so2901123ywm.12
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 10:59:28 -0700 (PDT)
In-Reply-To: <20110711.014845.1009062692530385177.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2011 at 1:48 AM, David Miller <davem@davemloft.net> wro=
te:
> +static inline u32 arp_hashfn(u32 key, const struct net_device *dev, =
u32 hash_rnd)
> +{
> + =A0 =A0 =A0 u32 val =3D key ^ dev->ifindex;
> +
> + =A0 =A0 =A0 return val * hash_rnd;
> +}

OK, I suggested this, and there's nothing obviously wrong with it.

But I would hope that someone actually vetted that this provides
enough variation between different hash_rnd values to avoid hash
chain attacks.

 - R.
