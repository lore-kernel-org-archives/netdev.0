From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: big picture UDP/IP performance question re 2.6.18 -> 2.6.32
Date: Mon, 03 Oct 2011 18:16:28 +0200
Message-ID: <1317658588.2442.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: starlight@binnacle.cx
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 03 octobre 2011 =C3=A0 11:25 -0400, starlight@binnacle.cx a =C3=
=A9crit :

> >Please send full "dmesg" output=20
>=20
> Attached.
>=20

Minor note :

It seems you use 4096 2MB hugepages, and your machine has 1GB pages
availabe, you could try to use them.

(boot cmd : hugepagesz=3D1GB hugepages=3D8 )
