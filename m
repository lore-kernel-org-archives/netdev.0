From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 2/3] ARM: mvebu: Add support for the network controller
 in Armada 375 SoC
Date: Fri, 4 Jul 2014 16:06:47 -0300
Message-ID: <20140704190647.GA29955@arch.cereza>
References: <1404498697-21978-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1404498697-21978-3-git-send-email-ezequiel.garcia@free-electrons.com>
 <53B6F796.3090004@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:60224 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752421AbaGDTHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2014 15:07:43 -0400
Content-Disposition: inline
In-Reply-To: <53B6F796.3090004@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04 Jul 10:51 PM, Sergei Shtylyov wrote:
> >+			/* Network controller */
> >+			pp2@f0000 {
> >+				compatible =3D "marvell,armada-375-pp2";
> >+				reg =3D <0xf0000 0xa000>, /* Packet Processor regs */
> >+				      <0xc0000 0x3060>, /* LMS regs */
> >+				      <0xc4000 0x100>,  /* eth0 regs */
> >+				      <0xc5000 0x100>;  /* eth1 regs */
>=20
>    Hm, why are the above two ranges not listed under the "ethernet" s=
ubnodes?
>=20

Because as far as I know, if we want to put reg =3D <...> properties in=
 a sub-node,
then the parent node has to be a bus, but that's not the case.

I can't remember where have I read that, I'll take a look at the refere=
nce.
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
