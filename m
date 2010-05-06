From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: udp: make short packet logging consistent with
 ipv4
Date: Thu, 06 May 2010 16:49:26 +0200
Message-ID: <1273157366.2853.10.camel@edumazet-laptop>
References: <1273153475-32363-1-git-send-email-bjorn@mork.no>
	 <1273153475-32363-2-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:63566 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754772Ab0EFOtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 10:49:31 -0400
Received: by bwz19 with SMTP id 19so21747bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 07:49:29 -0700 (PDT)
In-Reply-To: <1273153475-32363-2-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 15:44 +0200, Bj=C3=B8rn Mork a =C3=A9crit :
> Adding addresses and ports to the short packet log message,
> like ipv4/udp.c does it, makes these messages a lot more useful:
>=20
> [  822.182450] UDPv6: short packet: From [2001:db8:ffb4:3::1]:47839 2=
3715/178 to [2001:db8:ffb4:3:5054:ff:feff:200]:1234
>=20
> This requires us to drop logging in case pskb_may_pull() fails,
> which also is consistent with ipv4/udp.c
>=20
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> ---
>  net/ipv6/udp.c |   11 ++++++++---
>  1 files changed, 8 insertions(+), 3 deletions(-)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


