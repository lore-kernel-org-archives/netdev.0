From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: allow bond in mode balance-alb to
 work properly in bridge -try4.3
Date: Fri, 29 May 2009 01:52:32 -0700 (PDT)
Message-ID: <20090529.015232.113333227.davem@davemloft.net>
References: <20090527135351.GD1652@psychotron.englab.brq.redhat.com>
	<20090528110459.GE22391@psychotron.englab.brq.redhat.com>
	<4A1E7887.4000102@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jpirko@redhat.com, netdev@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, andy@greyhouse.net,
	oleg@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49226
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754094AbZE2Iwc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2009 04:52:32 -0400
In-Reply-To: <4A1E7887.4000102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 May 2009 13:41:59 +0200

> Jiri Pirko a =E9crit :
>> [PATCH net-next] bonding: allow bond in mode balance-alb to work pro=
perly in bridge -try4.3
>>=20
>> (updated)
>> changes v4.2 -> v4.3
>> - memcpy the address always, not just in case it differs from master=
->dev_addr
>> - compare_ether_addr_64bits() is not used so there is no direct need=
 to make new
>>   header file (I think it would be good to have bond stuff in separa=
te file
>>   anyway).
>=20
> Yes, this could be done in a future cleanup patch.
> I find this (short) version easier to review for a new feature.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
