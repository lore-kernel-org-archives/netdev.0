From: Jie Yang <Jie.Yang@Atheros.com>
Subject: RE: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Thu, 21 Jan 2010 13:37:41 +0800
Message-ID: <CDAFEDABF718A54BABD0DA5476695307455062E7@SHEXMB-01.global.atheros.com>
References: <1263767939.8876.94.camel@localhost>
	<20100118.154347.314005348620400016.anders@netinsight.net>
	<CDAFEDABF718A54BABD0DA5476695307443F1E8D@SHEXMB-01.global.atheros.com>
 <20100120.102704.295948365864962720.anders@netinsight.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"565404@bugs.debian.org" <565404@bugs.debian.org>,
	Xiong Huang <Xiong.Huang@Atheros.com>
To: =?iso-8859-1?Q?Anders_Bostr=F6m?= <anders@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 175.210.DSNET ([203.110.175.210]:35849 "EHLO mail.atheros.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750941Ab0AUFho convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 00:37:44 -0500
In-Reply-To: <20100120.102704.295948365864962720.anders@netinsight.net>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Anders Bostr=F6m <anders@netinsight.net>
> Sent: Wednesday, January 20, 2010 5:27 PM
> To: Jie Yang
> Cc: ben@decadent.org.uk; netdev@vger.kernel.org;
> 565404@bugs.debian.org; Xiong Huang
> Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e:
> TSO is broken
>
> >>>>> "JY" =3D=3D Jie Yang <Jie.Yang@Atheros.com> writes:
>
>  JY> Anders Bostr=F6m <anders@netinsight.net> wrote:
>  >> It is an ASUS M4A78 PRO motherboard with the Atheros  >>
> AR8121/AR8113/AR8114 on-board.
>  >>
>  >> >> ~25Mbyte/s performance. I get ~5000 retransmitted
> packets  >> per GByte  >> data, according to RetransSegs in
> >> /proc/net/snmp . wireshark in the  >> client show that the
>  >> server send out a sequence of frames. All but the  >>
> last  >> one are 1500 bytes IP-packets. The last one is
> shorter, but  >> the  >> IP-header still say 1500 byte. The
> client then  >> requests retransmit,  >> and the
> retransmitted frame arrives  >> with correct IP-header.
>
>  JY> i just test it on Linux localhost.localdomain
> 2.6.31.5-127.fc12.x86_64 #1 SMP Sat Nov 7 21:11:14 EST 2009
> x86_64 x86_64 x86_64 GNU/Linux.
>  JY> with hardware, Atheros AR8121/AR8113/AR8114 PCI-E
> Ethernet Controller (rev b0)  JY> device id : 1969:1026 (rev b0)
>
>  JY> i upload/download a 382M it work well with retransmit packet:
>
> Have you tested NFS over TCP? The block-size the application
> uses can have an effect on this. What application did you
> use? Block-size?
>
yes, I tested NFS over TCP.
