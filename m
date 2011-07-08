From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] packet: add an unlock on error in fanout_add()
Date: Fri, 08 Jul 2011 10:01:22 +0200
Message-ID: <1310112082.2333.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110708072812.GX18655@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46571 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201Ab1GHIBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 04:01:35 -0400
In-Reply-To: <20110708072812.GX18655@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 08 juillet 2011 =C3=A0 10:28 +0300, Dan Carpenter a =C3=A9c=
rit :
> We need to release the "fanout_mutex" here.
>=20
> Signed-off-by: Dan Carpenter <error27@gmail.com>
>=20

Thanks, was fixed yesterday :

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3D=
commit;h=3Dafe62c68cd3562c5f8e3ea293e82906dd5a87936



