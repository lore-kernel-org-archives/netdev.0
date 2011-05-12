From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix vlan_features propagation
Date: Thu, 12 May 2011 14:55:19 -0700 (PDT)
Message-ID: <20110512.145519.226776509.davem@davemloft.net>
References: <20110506175629.AF59713A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47889
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758797Ab1ELVzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 17:55:51 -0400
In-Reply-To: <20110506175629.AF59713A6A@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Fri,  6 May 2011 19:56:29 +0200 (CEST)

> Fix VLAN features propagation for devices which change vlan_features.
> For this to work, driver needs to make sure netdev_features_changed()
> gets called after the change (it is e.g. after ndo_set_features()).
>=20
> Side effect is that a user might request features that will never
> be enabled on a VLAN device.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
