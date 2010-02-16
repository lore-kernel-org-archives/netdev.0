From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: xfrm: avoid spinlock in get_acqseq() used by xfrm user
Date: Tue, 16 Feb 2010 14:09:56 +0100
Message-ID: <1266325796.3045.45.camel@edumazet-laptop>
References: <1266321682.6776.254.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:56209 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755919Ab0BPNKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 08:10:07 -0500
Received: by bwz19 with SMTP id 19so4307096bwz.28
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2010 05:10:03 -0800 (PST)
In-Reply-To: <1266321682.6776.254.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 f=C3=A9vrier 2010 =C3=A0 07:01 -0500, jamal a =C3=A9crit :
> Eric's version fixed it for pfkey. This one is for xfrm user.
> I thought about amortizing those two get_acqseq()s but it seems
> reasonable to have two of these sequence spaces for the two different
> interfaces.
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !


