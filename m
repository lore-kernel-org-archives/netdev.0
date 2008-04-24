From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH] RAW6: Do not allow set IPV6_CHECKSUM for ICMPv6 socket
Date: Thu, 24 Apr 2008 18:26:52 +0300
Message-ID: <200804241826.52507.rdenis@simphalempin.com>
References: <20080420.183835.02139171.yoshfuji@linux-ipv6.org> <20080424.034845.137470754.davem@davemloft.net> <20080424.211953.52921169.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ellre923@gmail.com, wangchen@cn.fujitsu.com,
	netdev@vger.kernel.org
To: YOSHIFUJI Hideaki /
	 =?utf-8?q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:33707 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254AbYDXPqS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 11:46:18 -0400
In-Reply-To: <20080424.211953.52921169.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Thursday 24 April 2008 15:19:53 YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E, vous avez =C3=A9crit=C2=A0:
> RFC3542 discusses about IPPROTO_IPV6 level IPV6_CHECKSUM socket optio=
n
> only. IPPROTO_RAW level IPV6_CHECKSUM socket option is undocumented L=
inux
> extension.  So, we are free to choose allowing setting that option on
> ICMPv6 socket as we have been doing.

I wonder why RFC3542 forbids the contentious case. Is it a security=20
consideration, that userland should not be allowed to create bogus ICMP=
v6=20
packets (IPV6_CHECKSUM can be set after dropping root after opening a r=
aw=20
socket, right?), or is it just some random IETF folklore ??

I'd note that my ndisc6 package does call setsockopt(SOL_IPV6,=20
ICMPV6_CHECKSUM). Fortunately, it does not check for error values, so I=
 don't=20
really care if this is changed.

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
