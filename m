From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: unalias tcp_skb_cb flags and ip_dsfield
Date: Tue, 27 Sep 2011 10:01:46 +0200
Message-ID: <1317110506.2541.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1316757739.2560.12.camel@edumazet-laptop>
	 <1317103249.2796.25.camel@edumazet-laptop>
	 <20110927.022025.1306291417181821045.davem@davemloft.net>
	 <201109271037.38786.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hkchu@google.com, ilpo.jarvinen@helsinki.fi, jhs@mojatatu.com
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:51425 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766Ab1I0IBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 04:01:35 -0400
Received: by yib18 with SMTP id 18so4977615yib.19
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 01:01:35 -0700 (PDT)
In-Reply-To: <201109271037.38786.christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 septembre 2011 =C3=A0 10:37 +0300, Christoph Paasch a =C3=A9=
crit :
> Hi,
>=20
> I realize that before "struct tcp_skb_cb" is a comment saying that it=
's 44=20
> bytes long.
>=20
> However, (as far as I can see) before Eric's change it was 42 bytes l=
ong and=20
> now it became 43 bytes.
>=20
> Wouldn't it make sense to change the comment, so that it's consistent=
 again=20
> with the real size of tcp_skb_cb ?

You are mistaken :)

There was a two bytes hole.

I took one byte for dsfield, and left one byte hole,

I added a comment to remind there is this hole

Thanks !
