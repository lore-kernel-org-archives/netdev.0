From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] tcp: RST: binding oif to iif for tcp v4
Date: Sat, 04 Feb 2012 08:44:23 +0100
Message-ID: <1328341463.2480.12.camel@edumazet-laptop>
References: <1328300212-18836-1-git-send-email-shawn.lu@ericsson.com>
	 <1328304719.2480.5.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5C9FB94@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57255 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845Ab2BDHo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 02:44:27 -0500
Received: by wgbdt10 with SMTP id dt10so4579022wgb.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 23:44:26 -0800 (PST)
In-Reply-To: <62162DF05402B341B3DB59932A1FA992B5B5C9FB94@EUSAACMS0702.eamcs.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 16:43 -0500, Shawn Lu a =C3=A9c=
rit :
> See inline.
> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
> Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 12:16 -0800, Shawn Lu a =C3=A9=
crit :
> > Binding RST packet outgoing interface to incomming interface for tc=
p=20
> > v4. This has few benefits:
> > 1. tcp_v6_send_reset already did that.
>=20
> I dont think so. ipv6 makes no special provision for RST.
> [shawn LU] it's in  tcp_v6_send_response line 899 of tcp_ipv6.c
>  fl6.flowi6_oif =3D inet6_iif(skb);
>=20

tcp_v6_send_response() is used to send RST _and_ ACK

Its not reserved to RST. Thats why I said "no _special_ provision for
RST"

I repeat my question :

Why do you believe only RST should be handled in a different manner tha=
n
other TCP messages ?

If we decide to break asymmetric routing, we should do it completely an=
d
document it.

It might already be broken for IPv6 and nobody cared / noticed.
