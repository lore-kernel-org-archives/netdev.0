From: David Miller <davem@davemloft.net>
Subject: Re: Linux 2.6.34-rc3 + CAN build problem
Date: Sat, 10 Apr 2010 22:16:18 -0700 (PDT)
Message-ID: <20100410.221618.226789099.davem@davemloft.net>
References: <4BC070E0.6070601@hartkopp.net>
	<20100410.155009.66184583.davem@davemloft.net>
	<4BC15AC7.3010904@freemail.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: socketcan@hartkopp.net, eric.dumazet@gmail.com,
	oliver.hartkopp@volkswagen.de, urs.thuermann@volkswagen.de,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nm127@freemail.hu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BC15AC7.3010904@freemail.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: N=E9meth M=E1rton <nm127@freemail.hu>
Date: Sun, 11 Apr 2010 07:14:47 +0200

> David Miller wrote:
>> From: Oliver Hartkopp <socketcan@hartkopp.net>
>> Date: Sat, 10 Apr 2010 14:36:48 +0200
>>=20
>>> So i wonder why Nemeth trapped into this problem ... probably an in=
clude file
>>> mix-up?
>>=20
>> Do you have CONFIG_DEBUG_STRICT_USER_COPY_CHECKS enabled in your
>> kernel config?
>=20
> CONFIG_DEBUG_STRICT_USER_COPY_CHECKS=3Dy

Just turn that off in your builds, it's for developers who want
to work on correcting those warnings, not you :-)
