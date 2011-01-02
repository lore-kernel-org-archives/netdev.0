From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 02 Jan 2011 22:55:29 +0100
Message-ID: <1294005329.2535.258.camel@edumazet-laptop>
References: <1293982286-15389-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293982286-15389-1-git-send-email-stefani@seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 02 janvier 2011 =C3=A0 16:31 +0100, stefani@seibold.net a =C3=
=A9crit :
> From: Stefani Seibold <stefani@seibold.net>
>=20
> Changelog:
> 31.12.2010 first proposal
> 01.01.2011 code cleanup and fixes suggest by Eric Dumazet
> 02.01.2011 kick away UDP-Lite support
>            change spin_lock_irq into spin_lock_bh
> 	   faster udpcp_release_sock
> 	   base is now linux-next

Since you depend on zlib_adler32(), you should add a dependence in
Kconfig so that its available

select ZLIB_INFLATE
