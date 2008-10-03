From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [net-next PATCH 14/16] iptables socket match
Date: Fri, 3 Oct 2008 10:04:23 -0400 (EDT)
Message-ID: <alpine.LNX.1.10.0810031002460.3893@fbirervta.pbzchgretzou.qr>
References: <20081001142431.4893.48078.stgit@este> <20081001142431.4893.56954.stgit@este> <48E493CC.9020502@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:42400 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbYJCOEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 10:04:24 -0400
In-Reply-To: <48E493CC.9020502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2008-10-02 05:26, Patrick McHardy wrote:

> KOVACS Krisztian wrote:
>> Add iptables 'socket' match, which matches packets for which a TCP/U=
DP
>> socket lookup succeeds.
>
> It seems sufficiently different from what xt_owner does to justify a =
separate
> module.

I am with you on that. However, I would have had liked=C2=A0=E2=80=94 a=
lready last year=C2=A0=E2=80=94
to have xt_owner revision 1 be called socket, because it is much more t=
han just
ownage that xt_owner currently plays with, and because it could have sa=
ved now
running around with yet another module.
Well, xt_socket at last! ;-)
