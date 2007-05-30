From: =?iso-8859-1?b?RW1tYW51ZWwgRnVzdOk=?= <emmanuel.fuste@laposte.net>
Subject: Re: [PCNET32] Lock solid with netconsole
Date: Wed, 30 May 2007 09:43:47 +0200
Message-ID: <JIUG4Z$FE429A5F18B9052E8E0CF6906B6CB68A@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "tsbogend" <tsbogend@alpha.franken.de>,
	"lsorense" <lsorense@csclub.uwaterloo.ca>,
	"pcnet32" <pcnet32@verizon.net>, "netdev" <netdev@vger.kernel.org>
To: "romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.laposte.net ([81.255.54.16]:48940 "EHLO mx.laposte.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750725AbXE3Hny convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 03:43:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Even if the driver-agnostic part of the irq processing can be interru=
pted
> locally, the irq handlers are run sequentially on a given cpu. It doe=
s not
> leave a lot of room for a deadlock-prone printk().
>=20
> It _can_ happen but I'd prefer to pinpoint a specific candidate path
> where it would have happened.
>=20
Hi,

Could this bug fix from Stephen Hemminger be another track to follow ?
http://marc.info/?l=3Dlinux-netdev&m=3D118048588011069&w=3D2
If you think so, I could give it a try whitout applying the "spin_lock_=
irqsave" patch.


---

Cr=E9ez votre adresse =E9lectronique prenom.nom@laposte.net=20
1 Go d'espace de stockage, anti-spam et anti-virus int=E9gr=E9s.

