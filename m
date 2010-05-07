From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: udp: fix short packet and bad checksum logging
Date: Thu, 06 May 2010 21:48:51 -0700 (PDT)
Message-ID: <20100506.214851.137842513.davem@davemloft.net>
References: <1273153475-32363-1-git-send-email-bjorn@mork.no>
	<1273157280.2853.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, netdev@vger.kernel.org, stable@kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48699
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750987Ab0EGEso convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 May 2010 00:48:44 -0400
In-Reply-To: <1273157280.2853.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 May 2010 16:48:00 +0200

> Le jeudi 06 mai 2010 =E0 15:44 +0200, Bj=F8rn Mork a =E9crit :
>> commit 2783ef23 moved the initialisation of saddr and daddr after
>> pskb_may_pull() to avoid a potential data corruption.  Unfortunately
>> also placing it after the short packet and bad checksum error paths,
>> where these variables are used for logging.  The result is bogus
>> output like
>>=20
>> [92238.389505] UDP: short packet: From 2.0.0.0:65535 23715/178 to 0.=
0.0.0:65535
>>=20
>> Moving the saddr and daddr initialisation above the error paths, whi=
le still
>> keeping it after the pskb_may_pull() to keep the fix from commit 278=
3ef23.
>>=20
>> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
>> Cc: stable@kernel.org
>> ---
>>  net/ipv4/udp.c |    6 +++---
>>  1 files changed, 3 insertions(+), 3 deletions(-)
>=20
> Well done :)
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> To be backported to 2.6.29 and up kernels ;)

Applied to net-2.6 and queued up for -stable, thanks!
