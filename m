From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: Re: iptables very slow after commit 784544739a25c30637397ace5489eeb6e15d7d49
Date: Sat, 11 Apr 2009 20:32:48 +0200
Message-ID: <200904112032.49335.a.miskiewicz@gmail.com>
References: <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain> <20090410.230016.176733137.davem@davemloft.net> <f73f7ab80904111112n7c95d06ei32eb1f081842ae41@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jengelh@medozas.de,
	paulmck@linux.vnet.ibm.com, torvalds@linux-foundation.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, kaber@trash.net,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Kyle Moffett <kyle@moffetthome.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <f73f7ab80904111112n7c95d06ei32eb1f081842ae41@mail.gmail.com>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 11 of April 2009, Kyle Moffett wrote:

> Almost all of the standard firewall tools (such as shorewall, etc) ar=
e
> already using iptables-restore command to load firewall rules,
> primarily because using separate iptables commands was *already* way
> too slow. =20

Some time ago there was batch patch that allowed to use standard shell =
format=20
of calling iptables but did everything at once:

http://lists.netfilter.org/pipermail/netfilter-devel/2004-
September/016704.html

It didn't get merged - no idea why.

--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
