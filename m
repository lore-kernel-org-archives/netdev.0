From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Fix net-2.6.22 on sparc
Date: Sat, 10 Mar 2007 01:56:16 +0100
Message-ID: <45F20230.8020204@cosmosbay.com>
References: <20070309.162404.99202412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:41304 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbXCJA4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 19:56:22 -0500
In-Reply-To: <20070309.162404.99202412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> Eric, please look at whole files you are editing :) I'm sure
> there is probably another case like this or two in the
> other platform socket ioctl allocations you made.
>=20
> Thanks.
>=20
> commit 9415518744729743b017da2e08a71c5bb0d94108
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Fri Mar 9 16:22:52 2007 -0800
>=20
>     [NET]: Fix SO_TIMESTAMPNS values allocated to sparc.
>    =20
>     They confliced with SO_BROADCAST which already uses the
>     value 0x0020.
>    =20
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Oh I see :( this one was really not easy to spot without close inspecti=
on :)

I just checked all arches and only sparc{64} have this strange SO_XXXX =
values=20
not linear. I wonder why this layout was chosen ?

