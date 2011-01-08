From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: factorize qdisc stats handling
Date: Sat, 08 Jan 2011 16:40:25 +0100
Message-ID: <1294501225.2709.453.camel@edumazet-laptop>
References: <20110106195614.20dbc402@nehalam>
	 <AANLkTi=pqZ3CwLTAZnhd-cyQNj8OSeBHsP_bFiH3hJ-_@mail.gmail.com>
	 <20110107200234.3f5e7ff8@nehalam>
	 <1294478789.2709.79.camel@edumazet-laptop>  <4D286823.8050707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	netdev@vger.kernel.org, Luigi Rizzo <rizzo@iet.unipi.it>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54894 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905Ab1AHPkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jan 2011 10:40:32 -0500
Received: by wwa36 with SMTP id 36so19437457wwa.1
        for <netdev@vger.kernel.org>; Sat, 08 Jan 2011 07:40:31 -0800 (PST)
In-Reply-To: <4D286823.8050707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 08 janvier 2011 =C3=A0 14:35 +0100, Jarek Poplawski a =C3=A9c=
rit :

> I guess you can't use qdisc_pkt_len() without qdisc_enqueue_root().
>=20

Indeed !

This TCQ_F_CAN_BYPASS thing is truly evil ;)

Hmm, this makes me thing we could add TCQ_F_CAN_BYPASS on SFQ.

Thanks !


