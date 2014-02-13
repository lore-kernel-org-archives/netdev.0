From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:phy:dp83640: Move all HW initialization to
 dp83640_config_init
Date: Thu, 13 Feb 2014 18:52:48 -0500 (EST)
Message-ID: <20140213.185248.1522198499299798192.davem@davemloft.net>
References: <1392301617-24354-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: stefan.sorensen@spectralink.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51591 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbaBMXwu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:52:50 -0500
In-Reply-To: <1392301617-24354-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
Date: Thu, 13 Feb 2014 15:26:57 +0100

> phy_init_hw not does a full PHY reset after the driver probe has
> finished, so any hw initialization done in the probe will be lost.
> Part of the timestamping functionality of the dp83640 is set up in th=
e
> probe and with that lost, enabling timestamping will cause a PHY
> lockup, requiring a hard reset / power cycle to recover.
>=20
> This patch moves all the HW initialization in dp83640_probe to
> dp83640_config_init.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>

Applied, thank you.
