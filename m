From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix display of local and remote sit endpoints
Date: Wed, 18 Mar 2009 18:57:06 -0700 (PDT)
Message-ID: <20090318.185706.06488534.davem@davemloft.net>
References: <alpine.LSU.2.00.0903091545430.2331@fbirervta.pbzchgretzou.qr>
	<200903141934.38915.rjw@sisk.pl>
	<87d4ch4m1f.fsf_-_@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rjw@sisk.pl, jengelh@medozas.de, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48239
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751391AbZCSB5U convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 21:57:20 -0400
In-Reply-To: <87d4ch4m1f.fsf_-_@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Mon, 16 Mar 2009 14:47:24 +0100

> ipv6: fix display of local and remote sit endpoints
>=20
> This fixes the regressions cause by
> commit 1326c3d5a4b792a2b15877feb7fb691f8945d203
> (v2.6.28-rc6-461-g23a12b1) broke the display of local and remote
> addresses of an SIT tunnel in iproute2.
>=20
> nt->parms is used by ipip6_tunnel_init() and therefore need to be
> initialized first.
>=20
> Tracked as http://bugzilla.kernel.org/show_bug.cgi?id=3D12868
>=20
> Reported-by: Jan Engelhardt <jengelh@medozas.de>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied, thanks.
