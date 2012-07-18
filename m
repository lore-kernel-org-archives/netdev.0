From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: qmi_wwan: make dynamic device IDs work
Date: Wed, 18 Jul 2012 09:32:31 -0700 (PDT)
Message-ID: <20120718.093231.1261199223562707423.davem@davemloft.net>
References: <1342559672-5893-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494Ab2GRQcc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:32:32 -0400
In-Reply-To: <1342559672-5893-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Tue, 17 Jul 2012 23:14:32 +0200

> The usbnet API use the device ID table to store a pointer to
> a minidriver. Setting a generic pointer for dynamic device
> IDs will in most cases make them work as expected.  usbnet
> will otherwise treat the dynamic IDs as blacklisted. That is
> rarely useful.
>=20
> There is no standard class describing devices supported by
> this driver, and most vendors don't even provide enough
> information to allow vendor specific wildcard matching. The
> result is that most of the supported devices must be
> explicitly listed in the device table.  Allowing dynamic IDs
> to work both simplifies testing and verification of new
> devices, and provides a way for end users to use a device
> before the ID is added to the driver.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied.
