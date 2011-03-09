From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net-next 0/8] Phonet: pipe protocol cleanup
Date: Wed, 09 Mar 2011 11:57:16 -0800 (PST)
Message-ID: <20110309.115716.193720915.davem@davemloft.net>
References: <201103091043.32391.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44948
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751214Ab1CIT4i convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 14:56:38 -0500
In-Reply-To: <201103091043.32391.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Wed, 9 Mar 2011 10:43:32 +0200

> 	Hello,
>=20
> As "promised", here is the cleaned up and unified Phonet pipe code.
> The same kernel can now support both old (e.g. Nokia N900) and new
> (e.g. ST-Ericsson U8500 SoC) modems.
>=20
> The following changes since commit 7b46ac4e77f3224a1befe032c77f1df31d=
1b42c4:
>=20
>   inetpeer: Don't disable BH for initial fast RCU lookup. (2011-03-08=
 14:59:28 -0800)
>=20
> are available in the git repository at:
>   git://git.remlab.net/linux-phonet.git master

Connects to that git server timeout, something is wrong.

sunset:/home/davem# tcpdump -i eth0 host git.remlab.net
tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 byte=
s
11:53:55.290558 IP sunset.davemloft.net.davemloft.net.58504 > yop.chewa=
=2Enet.git: Flags [S], seq 1785921252, win 4380, options [mss 1460,sack=
OK,TS val 437283616 ecr 0,nop,wscale 7], length 0
11:54:38.550165 IP sunset.davemloft.net.davemloft.net.51169 > yop.chewa=
=2Enet.git: Flags [S], seq 3171701698, win 4380, options [mss 1460,sack=
OK,TS val 437287941 ecr 0,nop,wscale 7], length 0
11:54:41.550544 IP sunset.davemloft.net.davemloft.net.51169 > yop.chewa=
=2Enet.git: Flags [S], seq 3171701698, win 4380, options [mss 1460,sack=
OK,TS val 437288242 ecr 0,nop,wscale 7], length 0
11:54:47.570532 IP sunset.davemloft.net.davemloft.net.51169 > yop.chewa=
=2Enet.git: Flags [S], seq 3171701698, win 4380, options [mss 1460,sack=
OK,TS val 437288844 ecr 0,nop,wscale 7], length 0

Although web access works just fine.

So I'll apply the patches manually.

Thanks.
