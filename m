From: chriss <mail_to_chriss@gmx.net>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan interface RX
Date: Mon, 14 Feb 2011 13:22:55 +0000 (UTC)
Message-ID: <loom.20110214T141934-88@post.gmane.org>
References: <4D32FC1C.3010905@simon.arlott.org.uk> <201101231845.20505.maciej.rutecki@gmail.com> <AANLkTimTz=kMmJ=YhyJv28WUrsbN=ygBt9e7dMJ3KGqB@mail.gmail.com> <201101241625.45367.maciej.rutecki@gmail.com> <loom.20110205T163216-459@post.gmane.org> <AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com> <loom.20110206T203347-475@post.gmane.org> <4D4FE100.5090808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:52392 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754364Ab1BNNXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Feb 2011 08:23:07 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PoyOQ-0001I3-OB
	for netdev@vger.kernel.org; Mon, 14 Feb 2011 14:23:06 +0100
Received: from hlle-4db8bf43.pool.mediaWays.net ([77.184.191.67])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 14 Feb 2011 14:23:06 +0100
Received: from mail_to_chriss by hlle-4db8bf43.pool.mediaWays.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 14 Feb 2011 14:23:06 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan <nicolas.2p.debian <at> gmail.com> writes:

> I think you should have a look at ebtables command, in particular, th=
e
BROUTING chain of broute=20
> table. If this chain ask the packet to be dropped, then bridge will i=
gnore it
and give a chance to=20
> the upper layer to use it. Upper layer might be IP, or in your partic=
ular
setup, VLAN.
>=20
> HTH,
>=20
> 	Nicolas.

Thank you very much for the ebtables hint.

I also tried to add the vlan to my bridge device but only droping the v=
lan
tagged paket with ebtables got it working.

I'm not sure if this is the wanted behavior for bridging vlan actions.
=2E.or my network setup is just to ..f%%%'ed up?!

Thanks nicolas

regards//chriss

