From: Pascal Hambourg <pascal.mail@plouf.fr.eu.org>
Subject: Re: [PATCH 1/2] IPv6: conntrack: Use protocol-related initialization
 routine to initial queues of IPv6 connection track
Date: Sat, 30 Oct 2010 20:41:03 +0200
Message-ID: <4CCC66BF.3040305@plouf.fr.eu.org>
References: <20100125.233254.35824860.davem@davemloft.net>	<4B5EE2C6.6010802@cn.fujitsu.com>	<4B5EE436.3040204@trash.net> <20100126.051147.256313206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, shanwei@cn.fujitsu.com,
	yasuyuki.kozakai@toshiba.co.jp, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bamako.nerim.net ([62.4.17.28]:53450 "EHLO bamako.nerim.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163Ab0J3Sqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Oct 2010 14:46:52 -0400
In-Reply-To: <20100126.051147.256313206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

David Miller a =E9crit :
>=20
> Anyways, meanwhile I'll apply the fix.  And yes I know it needs
> to go to stable too... :-)

It appears that the patch "ipv6: reassembly: use seperate reassembly
queues for conntrack and local delivery" went to both the 2.6.32 and
2.6.27 stable branches, but the fix from Shan Wei went to the 2.6.32
branch only, not to the 2.6.27 branch. However I checked that it applie=
s
 on the latest 2.6.27 release, and fixes the problem.

Could someone submit it for the next 2.6.27 stable release ? Or if I
have to do it, what is the process ?
Thanks.
