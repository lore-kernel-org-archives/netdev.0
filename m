From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] cdc_ncm: avoid discarding datagrams in rx
 path
Date: Fri, 16 Mar 2012 02:08:55 -0700 (PDT)
Message-ID: <20120316.020855.1767159205766118997.davem@davemloft.net>
References: <1331760373-1914-1-git-send-email-alexey.orishko@stericsson.com>
	<1331760373-1914-3-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, oliver@neukum.org,
	linux-usb@vger.kernel.org, gregkh@linuxfoundation.org,
	alexey.orishko@stericsson.com
To: alexey.orishko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36462 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161356Ab2CPJJD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 05:09:03 -0400
In-Reply-To: <1331760373-1914-3-git-send-email-alexey.orishko@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Alexey Orishko <alexey.orishko@gmail.com>
Date: Wed, 14 Mar 2012 22:26:12 +0100

> Changes:
> - removed a limit for amount of datagrams for IN NTB
> - using pointer to traverse NTB in rx_fixup()
> - renamed "temp" to "len" in rx_fixup()
> - do NTB sequence number check in rx path
> Tested on Intel/ARM.
>=20
> Reviewed-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
> Tested-by: Dmitry Tarnyagin <Dmitry.Tarnyagin@stericsson.com>
> Signed-off-by: Alexey Orishko <alexey.orishko@stericsson.com>

Applied.
