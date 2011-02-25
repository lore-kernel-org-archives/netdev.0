From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] sch_choke: add choke_skb_cb
Date: Fri, 25 Feb 2011 04:54:08 +0100
Message-ID: <1298606048.2659.20.camel@edumazet-laptop>
References: <1298605541.2659.18.camel@edumazet-laptop>
	 <20110224194812.6f96424d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54715 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186Ab1BYDyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 22:54:15 -0500
Received: by wwb39 with SMTP id 39so1651539wwb.1
        for <netdev@vger.kernel.org>; Thu, 24 Feb 2011 19:54:14 -0800 (PST)
In-Reply-To: <20110224194812.6f96424d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 24 f=C3=A9vrier 2011 =C3=A0 19:48 -0800, Stephen Hemminger a =C3=
=A9crit :

> Ideally class id should be u32, but then that would mean changing TC
> classifier id and that is hardwired into the API.
>=20
>=20

Yes, this is a bit disappointing, especially if we want to use rxhash
from external classifier (same problem for SFQ)



