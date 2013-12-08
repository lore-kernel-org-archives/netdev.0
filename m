From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH] bgmac: connect to PHY and make use of PHY device
Date: Sun, 08 Dec 2013 18:50:58 +0100
Message-ID: <52A4B182.6070803@hauke-m.de>
References: <1386374035-31762-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:38622 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758904Ab3LHRvJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 12:51:09 -0500
In-Reply-To: <1386374035-31762-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2013 12:53 AM, Rafa=C5=82 Mi=C5=82ecki wrote:
> We were already registering MDIO bus, but we were not connecting bgma=
c
> to the PHY. Add proper call and implement adjust link function to swi=
tch
> MAC into requested state.
> At the same time it's possible to drop our internal PHY management.
> This is a "standard" PHY, so the "Generic PHY" driver works perfectly
> fine with this. Don't duplicate the code.
> Finally make use of phy_ethtool_[gs]set functions instead implementin=
g
> them from scratch.
>=20
> This change was successfully tested on BCM5357. I was able to
> autonegotiate 1000Mb/s full duplex, as well as force any of the
> 10/100/1000 half/full modes.
>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
Nice patch.

Acked-by: Hauke Mehrtens <hauke@hauke-m.de>

> ---
>  drivers/net/ethernet/broadcom/bgmac.c |  190 +++++++++++------------=
----------
>  drivers/net/ethernet/broadcom/bgmac.h |   12 +--
>  2 files changed, 64 insertions(+), 138 deletions(-)
