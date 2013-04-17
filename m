From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: cdc_ether: silence sparse
 __CHECK_ENDIAN__ warning
Date: Wed, 17 Apr 2013 14:15:55 -0400 (EDT)
Message-ID: <20130417.141555.291218128238374912.davem@davemloft.net>
References: <1366186333-5378-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ming.lei@canonical.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966324Ab3DQSP4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 14:15:56 -0400
In-Reply-To: <1366186333-5378-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Wed, 17 Apr 2013 10:12:13 +0200

> Remove warning introduced by commit 418fc57 ("usbnet: cdc-ether: appl=
y
> usbnet_link_change"):
>=20
>    CHECK   .../drivers/net/usb/cdc_ether.c
>  .../drivers/net/usb/cdc_ether.c:409:46: warning: incorrect type in a=
rgument 2 (different base types)
>  .../drivers/net/usb/cdc_ether.c:409:46:    expected bool [unsigned] =
[usertype] <noident>
>  .../drivers/net/usb/cdc_ether.c:409:46:    got restricted __le16 [us=
ertype] wValue
>=20
> Cc: Ming Lei <ming.lei@canonical.com>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied.
