From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 02/16] net: change netdev->features to u32
Date: Mon, 24 Jan 2011 15:30:04 -0800 (PST)
Message-ID: <20110124.153004.232756003.davem@davemloft.net>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
	<d9fe088556152bd3b43390e0fb5ea20d83aef233.1295734271.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34573
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752813Ab1AXX33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 18:29:29 -0500
In-Reply-To: <d9fe088556152bd3b43390e0fb5ea20d83aef233.1295734271.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sat, 22 Jan 2011 23:14:12 +0100 (CET)

> Quoting Ben Hutchings: we presumably won't be defining features that
> can only be enabled on 64-bit architectures.
>=20
> Occurences found by `grep -r` on net/, drivers/net, include/
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

I'll apply this, with one change, adding the suggestion that
features and vlan_features be moved next to each other in
struct netdev, from Eric Dumazet.

Thanks.
