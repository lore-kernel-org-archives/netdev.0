From: Jie Yang <Jie.Yang@Atheros.com>
Subject: RE: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Wed, 20 Jan 2010 14:03:38 +0800
Message-ID: <CDAFEDABF718A54BABD0DA5476695307443F1E8D@SHEXMB-01.global.atheros.com>
References: <20100115.142502.968775035345957525.anders@netinsight.net>
	<1263767939.8876.94.camel@localhost>
 <20100118.154347.314005348620400016.anders@netinsight.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Xiong Huang <Xiong.Huang@Atheros.com>
To: =?iso-8859-1?Q?Anders_Bostr=F6m?= <anders@netinsight.net>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"565404@bugs.debian.org" <56
Return-path: <netdev-owner@vger.kernel.org>
Received: from 175.210.DSNET ([203.110.175.210]:26463 "EHLO mail.atheros.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751721Ab0ATGDn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 01:03:43 -0500
In-Reply-To: <20100118.154347.314005348620400016.anders@netinsight.net>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anders Bostr=F6m <anders@netinsight.net> wrote:

> It is an ASUS M4A78 PRO motherboard with the Atheros
> AR8121/AR8113/AR8114 on-board.
>
>  >> ~25Mbyte/s performance. I get ~5000 retransmitted packets
> per GByte  >> data, according to RetransSegs in
> /proc/net/snmp . wireshark in the  >> client show that the
> server send out a sequence of frames. All but the  >> last
> one are 1500 bytes IP-packets. The last one is shorter, but
> the  >> IP-header still say 1500 byte. The client then
> requests retransmit,  >> and the retransmitted frame arrives
> with correct IP-header.

i just test it on Linux localhost.localdomain 2.6.31.5-127.fc12.x86_64 =
#1 SMP Sat Nov 7 21:11:14 EST 2009 x86_64 x86_64 x86_64 GNU/Linux.
with hardware, Atheros AR8121/AR8113/AR8114 PCI-E Ethernet Controller (=
rev b0)
device id : 1969:1026 (rev b0)

i upload/download a 382M it work well with retransmit packet:

Tcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens Attemp=
tFails EstabResets CurrEstab InSegs OutSegs RetransSegs InErrs OutRsts
Tcp: 1 200 120000 -1 2 4 2 0 2 532501 220631 6 0 2

I also test it on kernel 2.6.33-rc1 sync from git. but it fail to boot =
kernel

