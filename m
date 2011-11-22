From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skb->timestamp == 0.000000 ?
Date: Tue, 22 Nov 2011 15:10:40 +0100
Message-ID: <1321971040.2474.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAJX4=r3wTn9v6-5oEpGdeKkFjKsRLZwc76tE9M4FiVJX4Lpisg@mail.gmail.com>
	 <20111121211140.GB24753@d2.suse.de>
	 <CAJX4=r2XBGGzMFgeKC-TvZ-WQ9skwoBFA5na_XiLNqDn0U9V+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin Poirier <benjamin.poirier@gmail.com>,
	netdev@vger.kernel.org
To: Felipe Dias <felipediassss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60819 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995Ab1KVOKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 09:10:44 -0500
Received: by fagn18 with SMTP id n18so435087fag.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 06:10:43 -0800 (PST)
In-Reply-To: <CAJX4=r2XBGGzMFgeKC-TvZ-WQ9skwoBFA5na_XiLNqDn0U9V+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 novembre 2011 =C3=A0 11:04 -0300, Felipe Dias a =C3=A9crit =
:

> who is responsible for enabling? Would not it be the driver?
>=20
> Some packets (icmp) appear timestamp other packages do not appear.
>=20
> I'm confused, in my mind, after the registration of the "protocol
> handler" (with dev_add_pack) any skb should have the timestamp.
>=20

This is not the trigger for timestamps.

You need to call setsockopt(SO_TIMESTAMP or SO_TIMESTAMPNS) on at least
one socket.
