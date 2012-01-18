From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: bpf_jit: fix divide by 0 generation
Date: Wed, 18 Jan 2012 17:01:51 +0100
Message-ID: <1326902511.2316.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120118022709.GA4167@linuxace.com>
	 <1326867428.2606.39.camel@edumazet-laptop>
	 <1326871835.2606.40.camel@edumazet-laptop>
	 <1326873533.2606.46.camel@edumazet-laptop>
	 <20120118155747.GA4991@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62809 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757942Ab2ARQBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 11:01:55 -0500
Received: by bkas6 with SMTP id s6so2920215bka.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 08:01:53 -0800 (PST)
In-Reply-To: <20120118155747.GA4991@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 07:57 -0800, Phil Oester a =C3=A9cri=
t :

> Got the following output after applying this fix (no panic this time)=
:
>=20
> proglen=3D231 !=3D oldproglen=3D235
> bpb_jit_compile fatal error
>=20
> Filter being used is 'not net a.b.x.112/28 and not net a.b.y.112/28'

Thanks !

It seems there is another bug, I'll send you a new patch once fixed.
