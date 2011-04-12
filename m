From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sky2: convert to hw_features
Date: Tue, 12 Apr 2011 14:51:43 -0700 (PDT)
Message-ID: <20110412.145143.260086200.davem@davemloft.net>
References: <20110410131321.8CD9713A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46617
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932397Ab1DLVwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 17:52:19 -0400
In-Reply-To: <20110410131321.8CD9713A64@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sun, 10 Apr 2011 15:13:21 +0200 (CEST)

> Caveats:
>  - driver modifies vlan_features on HW VLAN TX changes
>  - broken RX checksum will be reenabled on features change
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

It seems the checksum concern exists both before and after these
changes, so I'm going to apply this and you guys can send me a
fixup fir the RX checksum feature validation issue as a follow-on
patch.

Thanks!
