From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] RAW6: Do not allow set IPV6_CHECKSUM for ICMPv6 socket
Date: Fri, 25 Apr 2008 09:03:59 +0800
Message-ID: <48112DFF.8020003@cn.fujitsu.com>
References: <20080420.183835.02139171.yoshfuji@linux-ipv6.org> <20080424.034845.137470754.davem@davemloft.net> <20080424.211953.52921169.yoshfuji@linux-ipv6.org> <200804241826.52507.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net, ellre923@gmail.com,
	netdev@vger.kernel.org
To: =?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?= <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50865 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753353AbYDYBFj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 21:05:39 -0400
In-Reply-To: <200804241826.52507.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=C3=A9mi Denis-Courmont said the following on 2008-4-24 23:26:
> I'd note that my ndisc6 package does call setsockopt(SOL_IPV6,=20
> ICMPV6_CHECKSUM). Fortunately, it does not check for error values, so=
 I don't=20
  ^^^^^^^^^^^^^^^
Remi, should be setsockopt(SOL_IPV6, IPV6_CHECKSUM)?

> really care if this is changed.
>=20

David, should we make sure every common used userland package
will not be influenced by this change?
No influence packages:
iputils
iproute2
ndisc6
net-tools

