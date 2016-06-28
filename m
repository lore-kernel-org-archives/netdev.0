From: Joe Perches <joe@perches.com>
Subject: Re: [RFC 1/7] net: ethernet: bgmac: change bgmac_* prints to dev_*
 prints
Date: Tue, 28 Jun 2016 12:43:58 -0700
Message-ID: <1467143038.24287.50.camel@perches.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
	 <1467142484-11161-2-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, f.fainelli@gmail.com, hauke@hauke-m.de,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>, zajec5@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467142484-11161-2-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-06-28 at 15:34 -0400, Jon Mason wrote:
> The bgmac_* print wrappers call dev_* prints with the dev pointer fro=
m
> the bcma core.=A0=A0In anticipation of removing the bcma requirement =
for
> this driver, these must be changed to not reference that struct.=A0=A0=
So,
> simply change all of the bgmac_* prints to their dev_* counterparts.=A0=
=A0In
> some cases netdev_* prints are more appropriate, so change those as
> well.

Thanks, but...

> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
[]
> @@ -1515,7 +1516,7 @@ static void bgmac_get_drvinfo(struct net_device=
 *net_dev,
> =A0			=A0=A0=A0=A0=A0=A0struct ethtool_drvinfo *info)
> =A0{
> =A0	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
> -	strlcpy(info->bus_info, "BCMA", sizeof(info->bus_info));
> +	strlcpy(info->bus_info, "AXI", sizeof(info->bus_info));
> =A0}

Unrelated change?
