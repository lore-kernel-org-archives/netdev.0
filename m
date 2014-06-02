From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/8] cdc_ncm: fixes and conversion to sysfs
 API
Date: Mon, 02 Jun 2014 16:02:19 -0700 (PDT)
Message-ID: <20140602.160219.886445844785145387.davem@davemloft.net>
References: <1401435070-26721-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	alexey.orishko@gmail.com, oliver@neukum.org, mrkiko.rs@gmail.com,
	David.Laight@ACULAB.COM, larsm17@gmail.com, peter@stuge.se,
	gsuarez@smithmicro.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbaFBXCU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 19:02:20 -0400
In-Reply-To: <1401435070-26721-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Fri, 30 May 2014 09:31:02 +0200

> After considering the comments received after the ethtool coalesce
> support was commited, I have ended up concluding that we should
> remove it again, while we can, before it hits a release. The idea
> was not well enough thought through, and all comments received
> pointed to advantages of using a sysfs based API instead.
>=20
> This series removes the ethtool coalesce support and replaces it
> with sysfs attributes in a driver specific group under the netdev.
>=20
> The first 3 patches are unrelated fixes:
>=20
> patch 1: reducing truesize as discussed
> patch 2: fixing a potentional buffer overrun when changing tx_max
> patch 3: prevent framing errors when changing rx_max
>=20
> Changes v2:
>  - minor editorial changes to patch 8, as suggested by Peter Stuge

Generally speaking I wouldn't be OK with using sysfs for this stuff,
but you make a very convincing argument for doing so in this specific
case.

Series applied, thanks.
