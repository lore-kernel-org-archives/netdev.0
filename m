From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: remove meaningless
 /sys/module/bonding/parameters entries.
Date: Mon, 03 Jan 2011 11:32:12 -0800 (PST)
Message-ID: <20110103.113212.260088613.davem@davemloft.net>
References: <1293978915-29674-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	fubar@us.ibm.com
To: nicolas.2p.debian@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50466
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751783Ab1ACTbl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 14:31:41 -0500
In-Reply-To: <1293978915-29674-1-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
Date: Sun,  2 Jan 2011 15:35:15 +0100

> Only two bonding parameters are exposed in /sys/module/bonding:
>=20
> num_grat_arp
> num_unsol_na
>=20
> Those values are not module global, but per device.
>=20
> The per device values are available in /sys/class/net/<device>/bondin=
g.
>=20
> The values exposed in /sys/module/bonding are those given at module l=
oad time
> and only used as default values when creating a device. They are read=
-only and
> cannot change in any way.
>=20
> As such, they are mostly meaningless.

=46irst, you forgot to provide a proper "Signed-off-by: " line in your
patch submission, please read Documentation/SubmittingPatches

Secondly, you can't remove these, people might be using them.  It
could be useful, for example, to debug problems with passing module
parameters in.  This is the one way to find out what actually got
passed to the module when it loaded.

Therefore I'm not applying this patch, sorry.
