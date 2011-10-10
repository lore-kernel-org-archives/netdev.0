From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: e100 + VLANs?
Date: Mon, 10 Oct 2011 17:50:42 +0200
Message-ID: <1318261843.3227.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E90212D.8030009@msgid.tls.msk.ru>
	 <1318091046.5276.22.camel@edumazet-laptop> <4E9097C0.2030307@gmail.com>
	 <20111010101954.GB2840382@jupiter.n2.diac24.net>
	 <4E9307CB.4050704@msgid.tls.msk.ru>
	 <1318259152.3227.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111010151343.GB3260852@jupiter.n2.diac24.net>
	 <1318260235.3227.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111010152845.GC3260852@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Tokarev <mjt@tls.msk.ru>, jeffrey.t.kirsher@intel.com,
	netdev <netdev@vger.kernel.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:44345 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786Ab1JJPu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 11:50:28 -0400
Received: by ywb5 with SMTP id 5so5487509ywb.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 08:50:28 -0700 (PDT)
In-Reply-To: <20111010152845.GC3260852@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 octobre 2011 =C3=A0 17:28 +0200, David Lamparter a =C3=A9cr=
it :

> Huh? The remote sends the ARP request to ff:f..f:ff, which has a VLAN
> tag in both dumps - but the packet sent from the e100 only has a tag =
in
> its own tcpdump... so it might pretty much wind up on the wire withou=
t a
> tag due to some TX bug...
>=20

I read the reverse from the mail.

But this is probably the reverse :

MAC address of partner : 00:1f:c6:ef:e5:1b  (ASUSTek prefix)

MAC address of e100 : 00:90:27:30:6d:1c
