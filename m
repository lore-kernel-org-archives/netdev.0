From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: problem with noop and pfifo_fast Qdisc switching
Date: Thu, 19 Jan 2012 15:13:18 +0100
Message-ID: <1326982398.2249.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <81C3A93C17462B4BBD7E272753C105791FB3639775@EXDCVYMBSTM005.EQ1STM.local>
	 <1326978933.2249.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <81C3A93C17462B4BBD7E272753C105791FB3639811@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
To: Hemant-vilas RAMDASI <hemant.ramdasi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:57983 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab2ASONV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 09:13:21 -0500
In-Reply-To: <81C3A93C17462B4BBD7E272753C105791FB3639811@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 janvier 2012 =C3=A0 14:44 +0100, Hemant-vilas RAMDASI a =C3=
=A9crit :

> Yes, I mean machine going to suspend..
> The problem with this message is that it can be retried only a couple=
 of time.
> We saw a code where dev_deactivate is called which changes the Qdisc =
to 'noop'.=20
> I hope it will restore it in dev_activate() again when machine resume=
s. We are checking this.
> Is there any race between when dev_queue_xmit is called and dev_activ=
ate is still not complete?
>=20

No race, just dev_queue_xmit() returns an error ;)

There is no 'queue' at this level.

IP has sort of a (small) queue because of ARP resolution.
