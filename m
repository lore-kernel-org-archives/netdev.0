From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net_sched: qdisc_alloc_handle() can be too
 slow
Date: Tue, 03 Jan 2012 21:34:52 +0100
Message-ID: <1325622892.2611.11.camel@edumazet-laptop>
References: <1325584697.2320.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325584811.2320.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120103.130353.716810185692904362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dave.taht@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55181 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab2ACUe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 15:34:57 -0500
Received: by wgbdr13 with SMTP id dr13so28177904wgb.1
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 12:34:56 -0800 (PST)
In-Reply-To: <20120103.130353.716810185692904362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 03 janvier 2012 =C3=A0 13:03 -0500, David Miller a =C3=A9crit =
:

> Applied, thanks Eric.  I always cringed when I looked at this functio=
n :)
>=20

Yep :(

I'll add an IDR (and not a btree as I stated earlier) to get O(1)
allocations and qdisc_lookup(), it should help to optimize
qdisc_tree_decrease_qlen() [ Slow as hell for complex qdisc setups ]
