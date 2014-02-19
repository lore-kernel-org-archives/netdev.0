From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: tcp: RTO restart
Date: Wed, 19 Feb 2014 10:01:47 -0800
Message-ID: <1392832907.18849.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140218181205.GA7780@kau.se>
	 <50334B08-CD60-4C4C-9556-ACC758F75D7E@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Per Hurtig <per.hurtig@kau.se>, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com,
	Anna =?ISO-8859-1?Q?Brunstr=F6m?= <anna.brunstrom@kau.se>,
	Michael Welzl <michawe@ifi.uio.no>, ilpo.jarvinen@helsinki.fi
To: Andreas Petlund <apetlund@simula.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:52487 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754458AbaBSSBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 13:01:49 -0500
Received: by mail-pa0-f51.google.com with SMTP id ld10so724284pab.38
        for <netdev@vger.kernel.org>; Wed, 19 Feb 2014 10:01:48 -0800 (PST)
In-Reply-To: <50334B08-CD60-4C4C-9556-ACC758F75D7E@simula.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-19 at 18:17 +0100, Andreas Petlund wrote:
> I=E2=80=99ve applied and tested the patch on VMs with both 32 bit and=
 64 bit kernel.
>=20
> Acked-by: Andreas Petlund <apetlund@simula.no>
> Tested-by: Andreas Petlund <apetlund@simula.no>

Sure the patch applies, but what experimental results did you get ?

My concern is that TCP_SKB_CB(skb)->when doesn't account for sojourn
time in host queues (qdisc and device).=20

Note : Missing documentation for this new sysctl.

This patch certainly cannot be applied as is.

Thanks !
