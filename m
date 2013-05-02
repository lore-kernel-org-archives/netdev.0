From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Thu, 02 May 2013 14:06:48 -0400 (EDT)
Message-ID: <20130502.140648.1138582574178897490.davem@davemloft.net>
References: <20130502.133947.387694205526879673.davem@davemloft.net>
	<CAHXqBF+Xb0ZVo2tO-0m59JJDrwy5vYX6=jLbts_ZAv5Pk+7SCw@mail.gmail.com>
	<20130502.135542.1332946768988319212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dcbw@redhat.com, torvalds@linux-foundation.org,
	hayeswang@realtek.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mirqus@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130502.135542.1332946768988319212.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: David Miller <davem@davemloft.net>
Date: Thu, 02 May 2013 13:55:42 -0400 (EDT)

> From: Micha=A9=A9 Miros=A9=A9aw <mirqus@gmail.com>
> Date: Thu, 2 May 2013 19:47:25 +0200
>=20
>> Are you sure it's "flags"? /sys/class/net/*/features were removed so=
me
>> time ago, and flags don't depend on NETIF_F_*.
>=20
> Oh, it's flags, which is printed in raw hex by net/core/net-sysfs.c:
>=20
> NETDEVICE_SHOW(flags, fmt_hex);

Oh you're right, I'm confusing netdev->flags with netdev->features, my =
bad.

More coffee needed :)
