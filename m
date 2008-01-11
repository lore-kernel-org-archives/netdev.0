From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: [PATCH 1/5] spidernet: add missing initialization
Date: Fri, 11 Jan 2008 13:44:35 +0100
Message-ID: <200801111344.35652.jens@de.ibm.com>
References: <20080111.153859.-1300526764.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linasvepstas@gmail.com, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:45439 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758617AbYAKMoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 07:44:39 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m0BCicx3092788
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 12:44:38 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0BCibLc2699508
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 13:44:37 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0BCiaQO009391
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 13:44:37 +0100
In-Reply-To: <20080111.153859.-1300526764.kouish@swc.toshiba.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 11 January 2008, Ishizaki Kou wrote:
> This patch fixes initialization of "aneg_count" and "medium" fields i=
n
> spider_net_card to make spidernet driver correctly sets "link status"=
=2E
>=20
> Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>

Hi Ishizaki,

Linas has left the company and is no longer doing kernel related stuff,
so I suggest, given Jeff is ok with that, that the two of us take over
spidernet maintainership.

Jens

---

Change maintainership for spidernet.

Signed-off-by: Jens Osterkamp <jens@de.ibm.com>

Index: linux-2.6/MAINTAINERS
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/MAINTAINERS	2008-01-11 13:32:04.000000000 +0100
+++ linux-2.6/MAINTAINERS	2008-01-11 13:41:32.000000000 +0100
@@ -3613,8 +3613,10 @@
 S:	Supported
=20
 SPIDERNET NETWORK DRIVER for CELL
-P:	Linas Vepstas
-M:	linas@austin.ibm.com
+P:	Ishizaki Kou
+M:	kou.ishizaki@toshiba.co.jp
+P:	Jens Osterkamp
+M:	jens@de.ibm.com
 L:	netdev@vger.kernel.org
 S:	Supported
=20

IBM Deutschland Entwicklung GmbH
Vorsitzender des Aufsichtsrats: Martin Jetter
Gesch=E4ftsf=FChrung: Herbert Kircher=20
Sitz der Gesellschaft: B=F6blingen
Registergericht: Amtsgericht Stuttgart, HRB 243294
