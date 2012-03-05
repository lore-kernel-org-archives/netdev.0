From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: export netdev_stats_to_stats64
Date: Mon, 05 Mar 2012 06:20:04 -0800
Message-ID: <1330957204.2474.19.camel@edumazet-laptop>
References: <20120305113353.GA12969@Spy32>
	 <1330954326.2474.9.camel@edumazet-laptop>
	 <1330955921.2474.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Junchang Wang <junchangwang@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:48144 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932403Ab2CEOUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 09:20:07 -0500
Received: by pbcun15 with SMTP id un15so2828168pbc.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 06:20:07 -0800 (PST)
In-Reply-To: <1330955921.2474.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 mars 2012 =C3=A0 05:58 -0800, Eric Dumazet a =C3=A9crit :
> Some drivers use internal netdev stats member to store part of their
> stats, yet advertize ndo_get_stats64() to implement some 64bit fields=
=2E
>=20
> Allow them to use netdev_stats_to_stats64() helper to make the copy o=
f
> netdev stats before they compute their 64bit counters.

Oh well, I forgot the include file in the commit, I'll send a v2
