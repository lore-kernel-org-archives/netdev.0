From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: unalias tcp_skb_cb flags and ip_dsfield
Date: Tue, 27 Sep 2011 11:40:25 +0200
Message-ID: <1317116425.2541.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1317103249.2796.25.camel@edumazet-laptop>
	 <201109271138.00318.christoph.paasch@uclouvain.be>
	 <1317115409.2541.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <201109271228.44232.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hkchu@google.com, ilpo.jarvinen@helsinki.fi, jhs@mojatatu.com
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:39242 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868Ab1I0JkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 05:40:14 -0400
Received: by ywb5 with SMTP id 5so5122772ywb.19
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 02:40:13 -0700 (PDT)
In-Reply-To: <201109271228.44232.christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 septembre 2011 =C3=A0 12:28 +0300, Christoph Paasch a =C3=A9=
crit :

>=20
> Ok, I understand.
> Thanks for the info. I didn't knew this...
>=20
> It's good news...
> Maybe we win now a little bit of space in MultiPath TCP by rearrangin=
g our=20
> fields... :-)

To ease your task, I suggest you take a look at pahole

http://lwn.net/Articles/365844/
