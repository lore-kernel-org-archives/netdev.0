From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 2/4] caif: Add support for CAIF over CDC NCM
 USB interface
Date: Mon, 05 Dec 2011 18:46:10 -0500 (EST)
Message-ID: <20111205.184610.220810223801058769.davem@davemloft.net>
References: <1323033775-3496-1-git-send-email-sjur.brandeland@stericsson.com>
	<1323033775-3496-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, alexey.orishko@stericsson.com,
	eric.dumazet@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932481Ab1LEXqQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 18:46:16 -0500
In-Reply-To: <1323033775-3496-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Sun,  4 Dec 2011 22:22:53 +0100

> NCM 1.0 does not support anything but Ethernet framing, hence
> CAIF payload will be put into Ethernet frames.
>=20
> Discovery is based on fixed USB vendor 0x04cc (ST-Ericsson),
> product-id 0x230f (NCM). In this variant only CAIF payload is sent ov=
er
> the NCM interface.
>=20
> The CAIF stack (cfusbl.c) will when USB interface register first chec=
k if
> we got a CDC NCM USB interface with the right VID, PID.
> It will then read the device's Ethernet address and create a 'templat=
e'
> Ethernet TX header, using a broadcast address as the destination addr=
ess,
> and EthType 0x88b5 (802.1 Local Experimental - vendor specific).
>=20
> A protocol handler for 0x88b5 is setup for reception of CAIF frames f=
rom
> the CDC NCM USB interface.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
