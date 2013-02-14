From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cdc_ncm: fix probing of devices with multiple
 control interface altsettings
Date: Thu, 14 Feb 2013 13:15:16 -0500 (EST)
Message-ID: <20130214.131516.1338992153364367929.davem@davemloft.net>
References: <1360793392-7412-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	gsuarez@smithmicro.com, alexey.orishko@stericsson.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758482Ab3BNSPT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 13:15:19 -0500
In-Reply-To: <1360793392-7412-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Wed, 13 Feb 2013 23:09:52 +0100

> commit bd329e1 ("net: cdc_ncm: do not bind to NCM compatible MBIM dev=
ices")
> added a test for a CDC MBIM altsetting, implementing the cdc_ncm part=
 of
> MBIM backward compatibility support.  This intentionally made the dri=
ver
> behave differently for CDC NCM devices with 2 alternate settings for =
the
> Communication interface, depending on whether or not CONFIG_USB_NET_C=
DC_MBIM
> was enabled.  This is correct iff alternate setting #1 really *is* a =
MBIM
> setting.  If not, then NCM probing will use a different altsetting th=
an before,
> possibly causing probing failures depending on CONFIG_USB_NET_CDC_MBI=
M.
>=20
> Fix by setting the altsetting back to default after the test, restori=
ng the
> previous behaviour for non MBIM devices.
>=20
> This bug causes probing of Huawei E3276 devices to fail when the MBIM=
 driver
> is enabled, because these devices have a second alternate setting wit=
h no CDC
> functional descriptors.
>=20
> Cc: Greg Suarez <gsuarez@smithmicro.com>
> Cc: Alexey Orishko <alexey.orishko@stericsson.com>
> Reported-and-tested-by: Jonathan A. <yo.natan@hotmail.com>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied.
