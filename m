From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Add NAPI support to ll_temac driver
Date: Tue, 19 Apr 2011 15:21:53 +0200
Message-ID: <1303219313.3480.174.camel@edumazet-laptop>
References: <4DAD5753.4040108@monstr.eu>
	 <1303209787.3480.9.camel@edumazet-laptop>
	 <1303215925.3464.54.camel@localhost>  <4DAD84B1.9020405@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40504 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754231Ab1DSNV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 09:21:58 -0400
Received: by wya21 with SMTP id 21so4798722wya.19
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 06:21:57 -0700 (PDT)
In-Reply-To: <4DAD84B1.9020405@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 avril 2011 =C3=A0 14:48 +0200, Michal Simek a =C3=A9crit :

> About SKB allocation. I fixed our non mainline driver to allocate skb=
 based on=20
> current mtu size. Mainline driver allocate max mtu (9k). This has als=
o impact on=20
> performance because Microblaze works with smaller SKBs.
>=20

Make sure it wont crash/freeze if some evil guy sends a big frame



