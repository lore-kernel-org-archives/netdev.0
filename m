From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Fri, 21 Dec 2007 07:06:13 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0712210701470.21721@fbirervta.pbzchgretzou.qr>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>
 <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com>
 <4768123A.7040603@cosmosbay.com>  <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
  <47682F8C.20205@cosmosbay.com>  <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com>
  <47694FCC.1020507@cosmosbay.com>  <83a51e120712190943m3bf0e2e4v2ea6b660142e9a5a@mail.gmail.com>
  <Pine.LNX.4.64.0712191857270.12329@fbirervta.pbzchgretzou.qr>
 <1198161695.6154.47.camel@andromache> <83a51e120712200837p9e3d1a4g15b5f4763597073e@mail.gmail.com>
 <Pine.LNX.4.64.0712202247410.20288@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Nichols <jamesnichols3@gmail.com>,
	Glen Turner <gdt@gdt.id.au>,
	Eric Dumazet <dada1@cosmosbay.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:36833 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbXLUGGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 01:06:14 -0500
In-Reply-To: <Pine.LNX.4.64.0712202247410.20288@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 20 2007 23:05, Ilpo J=C3=A4rvinen wrote:
>>=20
>> Given the fact that I've had this problem for so long, over a variet=
y
>> of networking hardware vendors and colo-facilities, this really soun=
ds
>> good to me.  It will be challenging for me to justify a kernel core
>> dump, but a simple patch to dump the Sack data would be do-able.
>
>If your symptoms really are: SYNs leaving (if they show up in tcpdump,=
 for=20
>sure they've left TCP code already) and SYN-ACK not showing up even in=
=20
>something as early as in tcpdump (for sure TCP side code didn't execut=
e at=20
>that point yet), there's very little change that Linux' TCP code has s=
ome=20
>bug in it, only things that do something in such scenario are the SYN=20
>generation and retransmitting SYNs (and those are trivially verifiable=
=20
>from tcpdump).
>
Take a machine, put two interfaces in it, configure as bridge (br0
over eth0 and eth1 without any assigned ip addresses), put it between
end node and the cisco. tcpdump there, which should give an unbiased
view wrt. endnode/cisco. Then perhaps, also configure such a network
listening bridge on the other side of the cisco, e.g. on the link to
the internet and watch that. Compare the two tcpdumpds and see if
sack got trashed.
