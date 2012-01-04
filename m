From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible DoS with 6RD border relay
Date: Wed, 04 Jan 2012 18:25:31 +0100
Message-ID: <1325697931.2428.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <201201041048.44509.bcook@breakingpoint.com>
	 <201201041102.31205.bcook@breakingpoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Brent Cook <bcook@breakingpoint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50721 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756472Ab2ADRZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 12:25:35 -0500
Received: by wgbdr13 with SMTP id dr13so29254399wgb.1
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2012 09:25:34 -0800 (PST)
In-Reply-To: <201201041102.31205.bcook@breakingpoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 04 janvier 2012 =C3=A0 11:02 -0600, Brent Cook a =C3=A9crit=
 :

> I forgot to mention, I'm testing 3.2 rc7:
>=20
> Linux target1 3.2.0-7-generic #13-Ubuntu SMP Sat Dec 24 18:06:57 UTC =
2011=20
> x86_64 x86_64 x86_64 GNU/Linux
>=20
> but the same behavior occurs with 2.6.35

Please check :

grep . /proc/sys/net/ipv6/route/*
