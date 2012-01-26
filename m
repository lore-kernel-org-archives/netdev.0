From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BISECTED] Linux 3.2: Networking out of LAN does not work
Date: Thu, 26 Jan 2012 07:01:13 +0100
Message-ID: <1327557673.2605.22.camel@edumazet-laptop>
References: <OF0BD4E9BA.3C3D7E41-ONC1257990.0034993D-C1257990.0034B2CE@bdpnet.dk>
	 <1327484459.2425.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1327489531.2425.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120125.214146.1725158231070595211.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rum@bankdata.dk, netdev@vger.kernel.org, mihai.maruseac@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:48431 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837Ab2AZGBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 01:01:18 -0500
Received: by werb13 with SMTP id b13so124753wer.19
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2012 22:01:16 -0800 (PST)
In-Reply-To: <20120125.214146.1725158231070595211.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 janvier 2012 =C3=A0 21:41 -0500, David Miller a =C3=A9cr=
it :

> Sorry, we never promised to list devices in any particular order,
> any such dependency is a bug and must be fixed instead of papered
> around by the kernel.
>=20
> This same issue came up for routes too once we deleted fib_hash
> and fib_trie listed them in a different order.
>=20
> I'm not applying this.


I once hit this exact issue with a legacy commercial product using a
licence based on MAC address, and could fix it using a custom
"ifconfig", since last ifconfig versions sort the device list before
output.

I personally dont care, but apparently Rune spent time to bisect the
problem. I presumed it was an issue for him.

Since Rune didnt answer to my mail, I wont argue with you :)
