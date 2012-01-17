From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Bugzilla 42595
Date: Wed, 18 Jan 2012 00:43:47 +0100
Message-ID: <1326843827.2606.35.camel@edumazet-laptop>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F15D417.4050005@fud.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45148 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080Ab2AQXny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 18:43:54 -0500
Received: by wgbdq11 with SMTP id dq11so2534071wgb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 15:43:53 -0800 (PST)
In-Reply-To: <4F15D417.4050005@fud.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 janvier 2012 =C3=A0 21:03 +0100, Tore Anderson a =C3=A9crit=
 :

>=20
> 3) There seems to be a bug related to generating the TCP checksum of
> SYN/ACK packets to destinations with the allfrag features set. I just
> submitted a bug report about this:
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D42595
>=20
> This makes the allfrag feature pretty much useless for me, as I can o=
nly
> successfully establish a single TCP session from a client behind a <1=
280
> MTU link for the entire lifetime of the routing cache entry.
>=20

It seems we dont handle skb ip_summed CHECKSUM_PARTIAL=20
in ip6_fragment() slow_path
