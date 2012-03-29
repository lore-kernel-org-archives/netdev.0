From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION][PATCH] bpf_jit drops the ball on indirect negative
 mem references
Date: Thu, 29 Mar 2012 15:57:55 +0200
Message-ID: <1333029475.3402.24.camel@edumazet-laptop>
References: <CAPwCz79wO=5zTZmCG+ePfRuEu-p_Vosi18bYZ-MVNZGOdbE3aQ@mail.gmail.com>
	  <1332965129.2325.12.camel@edumazet-glaptop>
	  <CAPwCz7_tnjq32duJSDj21LpRe5TFvGGszH4joQr1DGTjNd7GcA@mail.gmail.com>
	 <1332967172.2325.22.camel@edumazet-glaptop>
	 <4F744D58.3070009@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Matt Evans <matt@ozlabs.org>
To: Jan Seiffert <kaffeemonster@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39647 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079Ab2C2N6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 09:58:16 -0400
In-Reply-To: <4F744D58.3070009@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 mars 2012 =C3=A0 13:54 +0200, Jan Seiffert a =C3=A9crit :

> Ok, to keep the ball rolling here is a V2 with the changes you sugges=
ted:
>=20
=2E..

> I propose the following patch to fix this situation.
> Lightly tested on x86, but the powerpc asm part is prop. wrong.
>=20
>=20
> Signed-of-by: Jan Seiffert <kaffeemonster@googlemail.com>
>=20

x86 part seems very good at first glance, I'll test it and give my
feedback soon.

Thanks !
