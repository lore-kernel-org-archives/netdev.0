From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 30092] New: smsc911x.c drops long packets
 with VLAN tags
Date: Mon, 07 Mar 2011 12:31:03 -0800 (PST)
Message-ID: <20110307.123103.115933638.davem@davemloft.net>
References: <bug-30092-10286@https.bugzilla.kernel.org/>
	<20110301161547.13480e90.akpm@linux-foundation.org>
	<lnsjv58vl2.fsf@desktop3.csbnet.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, steve.glendinning@smsc.com
To: weinholt@csbnet.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752990Ab1CGUa0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 15:30:26 -0500
In-Reply-To: <lnsjv58vl2.fsf@desktop3.csbnet.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: weinholt@csbnet.se (G=F6ran Weinholt)
Date: Wed, 02 Mar 2011 15:07:21 +0100

> Subject: [PATCH] net/smsc911x.c: Set the VLAN1 register to fix VLAN M=
TU problem
> From: G=F6ran Weinholt <weinholt@csbnet.se>
>=20
> The smsc911x driver would drop frames longer than 1518 bytes, which i=
s a
> problem for networks with VLAN tagging. The VLAN1 tag register is use=
d
> to increase the legal frame size to 1522 when a VLAN tag is identifie=
d.
>=20
> Signed-off-by: G=F6ran Weinholt <weinholt@csbnet.se>

Applied, thanks.
