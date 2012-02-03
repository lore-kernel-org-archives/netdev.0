From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Connect hangs for a while before returns -1 with ECONNREFUSED
 on 3.2 for loopback
Date: Fri, 03 Feb 2012 16:15:26 +0100
Message-ID: <1328282126.2157.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F2B7DF1.5050303@oktetlabs.ru>
	 <1328279894.2157.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:61125 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732Ab2BCPPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 10:15:30 -0500
Received: by wics10 with SMTP id s10so2680611wic.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 07:15:29 -0800 (PST)
In-Reply-To: <1328279894.2157.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 15:38 +0100, Eric Dumazet a =C3=
=A9crit :

>=20
> Hmmm...
>=20

We omit to send RST packet in tcp_v4_send_reset()

because of this test :

if (skb_rtable(skb)->rt_type !=3D RTN_LOCAL)
	return

At this point rt_type is RTN_UNICAST
