From: David Miller <davem@davemloft.net>
Subject: Re: Fix FRTO+NewReno problem
Date: Mon, 12 May 2008 15:48:38 -0700 (PDT)
Message-ID: <20080512.154838.163999274.davem@davemloft.net>
References: <Pine.LNX.4.64.0805121656440.1888@wrl-59.cs.helsinki.fi>
	<48288EFE.4020708@damtek.com>
	<Pine.LNX.4.64.0805122143080.14152@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: damon@damtek.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55829
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755031AbYELWsn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 18:48:43 -0400
In-Reply-To: <Pine.LNX.4.64.0805122143080.14152@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 12 May 2008 22:12:47 +0300 (EEST)

> Then one question for DaveM:
>=20
> What I'm not fully sure of, is do we want this workaround to be a sys=
ctl=20
> or unconditionally enabled which causes potentially up to two unneces=
sary=20
> retransmissions? With SACK one or both of them will get SACKed before=
 they=20
> get retransmitted (both cases have common scenarios). (I made that=20
> workaround patch for 2.6.24.1, so YMMV if you just plainly try to app=
ly it=20
> to net-2.6).

I think we will have to handle this behavior, unconditionally, all
the time.  Don't even add the sysctl.

If I understand correctly, it is only non-SACK newreno case that can
get the unnecessary retransmissions, right?  If so, it's not a big
deal at all.
