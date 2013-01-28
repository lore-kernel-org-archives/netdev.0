From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cdc_ncm: use IAD provided by the USB core
Date: Sun, 27 Jan 2013 19:28:03 -0500 (EST)
Message-ID: <20130127.192803.1807601748904442959.davem@davemloft.net>
References: <1359193020-12873-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	oliver@neukum.org, gsuarez@smithmicro.com,
	alexey.orishko@stericsson.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36793 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039Ab3A1A2F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 19:28:05 -0500
In-Reply-To: <1359193020-12873-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Sat, 26 Jan 2013 10:36:59 +0100

> commit 9992c2e (net: cdc_ncm: workaround for missing CDC Union)
> added code to lookup an IAD for the interface we are probing.
> This is redundant.  The USB core has already done the lookup
> and saved the result in the USB interface struct.  Use that
> instead.
>=20
> Cc: Greg Suarez <gsuarez@smithmicro.com>
> Cc: Alexey Orishko <alexey.orishko@stericsson.com>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied to 'net'.
