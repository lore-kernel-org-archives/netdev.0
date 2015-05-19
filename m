From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: ingress policying for realtime protocol
Date: Tue, 19 May 2015 23:11:45 +0200
Message-ID: <20150519211145.GA23134@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51547 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbbESVLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 17:11:47 -0400
Received: from dude.hi.pengutronix.de ([2001:67c:670:100:1d::7])
	by metis.ext.pengutronix.de with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <ukl@pengutronix.de>)
	id 1Yuonh-0004OU-QR
	for netdev@vger.kernel.org; Tue, 19 May 2015 23:11:45 +0200
Received: from ukl by dude.hi.pengutronix.de with local (Exim 4.84)
	(envelope-from <ukl@pengutronix.de>)
	id 1Yuonh-0001uH-Jj
	for netdev@vger.kernel.org; Tue, 19 May 2015 23:11:45 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I hope this is the/a right list to ask this question. If not, I'd be
happy to learn the right alternative.

=46or a system that implements the Media Redundancy Protocol (MRP,
http://en.wikipedia.org/wiki/Media_Redundancy_Protocol) I'm faced with
the task to assert that the corresponding ethernet packets are handled
"in time". Currently this fails already if I do

	scp somebigfile mymrpsystem:

The first idea was to use ingress policying to limit all packets that
are not related to MRP to a certain rate.

The problem in practise however is that the rate that has to be used
above is very low (100kbit) so we're looking for alternatives. I wonder
what's missing to get ingress policying more versatile to allow for
example a prio qdisc or if there is some conceptual problem that I don'=
t
see. I'm not sure this would solve our problem, but it's definitely
something I want to play with before trying/resorting to hackish
solutions (like hacking the eth-driver to pipe MRP packets directly to
the network userspace application instead of through the network stack)=
=2E

Do you have any ideas or hints?

Thanks in advance
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
