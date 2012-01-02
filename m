From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sch_qfq: fix overflow in qfq_update_start()
Date: Mon, 02 Jan 2012 22:45:06 +0100
Message-ID: <1325540706.2874.3.camel@edumazet-laptop>
References: <1325519277.2375.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Dave Taht <dave.taht@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62390 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523Ab2ABVpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 16:45:11 -0500
Received: by wgbdr13 with SMTP id dr13so26997632wgb.1
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 13:45:10 -0800 (PST)
In-Reply-To: <1325519277.2375.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 02 janvier 2012 =C3=A0 16:47 +0100, Eric Dumazet a =C3=A9crit =
:
> grp->slot_shift is between 22 and 41, so using 32bit wide variables i=
s
> probably a typo.
>=20
> This could explain QFQ hangs Dave reported to me, after 2^23 packets =
?
>=20
> (23 =3D 64 - 41)
>=20
> Reported-by: Dave Taht <dave.taht@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: Dave Taht <dave.taht@gmail.com>

Oh well, I forgot my SOB :(

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

David please just tell me if you prefer me to resend it
