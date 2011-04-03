From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vlan: convert VLAN devices to use ndo_fix_features()
Date: Sat, 02 Apr 2011 22:50:25 -0700 (PDT)
Message-ID: <20110402.225025.98880429.davem@davemloft.net>
References: <20110331110135.19BE6138DD@rere.qmqm.pl>
	<AANLkTim68LoiyFA4+3weHkmuVpc=xxmHnheiEf_OH0LK@mail.gmail.com>
	<20110402144141.0666C1389B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jesse@nicira.com, kaber@trash.net,
	john.r.fastabend@intel.com, eric.dumazet@gmail.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45748
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751501Ab1DCFvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 01:51:03 -0400
In-Reply-To: <20110402144141.0666C1389B@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sat,  2 Apr 2011 16:41:41 +0200 (CEST)

> Note: get_flags was actually broken, because it should return the
> flags capped with vlan_features. This is now done implicitly by
> limiting netdev->hw_features.
>=20
> RX checksumming offload control is (and was) broken, as there was no =
way
> before to say whether it's done for tagged packets.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
