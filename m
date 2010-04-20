From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Tue, 20 Apr 2010 15:16:44 +0200
Message-ID: <1271769404.7895.10.camel@edumazet-laptop>
References: <1271452358.16881.4486.camel@edumazet-laptop>
	 <1271520633.16881.4754.camel@edumazet-laptop>
	 <20100419.130905.210660275.davem@davemloft.net>
	 <20100419.132318.192086187.davem@davemloft.net>
	 <1271709121.3845.94.camel@edumazet-laptop>
	 <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>
	 <1271743164.3845.128.camel@edumazet-laptop>
	 <1271750198.3845.216.camel@edumazet-laptop>
	 <4BCDA2B5.4060609@lastsummer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Franco Fichtner <franco@lastsummer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:41751 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488Ab0DTNQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 09:16:57 -0400
Received: by bwz19 with SMTP id 19so10783bwz.21
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 06:16:56 -0700 (PDT)
In-Reply-To: <4BCDA2B5.4060609@lastsummer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 avril 2010 =C3=A0 14:48 +0200, Franco Fichtner a =C3=A9crit=
 :

>=20
> I thought about this for some time...
>=20
> Do we really need the port numbers here at all? A simple
> addr1^addr2 can provide a good enough pointer for
> distribution amongst CPUs.
>=20
> The real connection tracking is better done locally at the
> corresponding CPU. That way a potential cache miss can be
> avoided and the still needed hash calculation for
> connection tracking will be offloaded.
>=20

Yes, doing the port test/swap is useful in the loopback case=20
(addr1 =3D=3D addr2).

This is probably a bit convoluted, but David (and me) found this
funny ;)


