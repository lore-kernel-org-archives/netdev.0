From: Jens Osterkamp <jens@linux.vnet.ibm.com>
Subject: Re: 802.1ad on linux
Date: Thu, 28 Jul 2011 13:21:46 +0200
Message-ID: <201107281321.46294.jens@linux.vnet.ibm.com>
References: <CAChS5kM+xmWRrF-Ez7W9+=7Se9o3bXrk4sSs6X-z7gU21SaWrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Satendra..." <satendra.pratap@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([194.196.100.163]:41809 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481Ab1G1LWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 07:22:03 -0400
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate3.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p6SBLllP018141
	for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 11:21:47 GMT
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6SBLlA82195532
	for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 12:21:47 +0100
Received: from d06av05.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6SBLlQs030442
	for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 05:21:47 -0600
In-Reply-To: <CAChS5kM+xmWRrF-Ez7W9+=7Se9o3bXrk4sSs6X-z7gU21SaWrA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 July 2011, Satendra... wrote:
> Hi,
>=20
> Does linux kernel has support for 802.1ad ? if yes could u plz mentio=
n
> the version?

No, but David Lamparter has just recently posted patches which implemen=
t this.

http://marc.info/?l=3Dlinux-netdev&m=3D131093613717022&w=3D2

They work fine for me on top of net-next. I had to add EXPORT_SYMBOL fo=
r
vlan_untag and vlan_do_receive to be able to build as a module.
You will need his patch for iproute2 as well to be able to create 802.1=
ad
VLAN devices.

Jens

--=20

IBM Deutschland Research & Development GmbH
Vorsitzender des Aufsichtsrats: Martin Jetter
Gesch=E4ftsf=FChrung: Dirk Wittkopp
Sitz der Gesellschaft: B=F6blingen
Registergericht: Amtsgericht Stuttgart, HRB 243294
