From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Tue, 24 Feb 2015 18:47:30 +0100
Message-ID: <CACna6rzNGTNdH9=msHL-e9ot=beF0bBiUBrx01f9Ydf4N7dJOQ@mail.gmail.com>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jonas Gorski <jogo@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:41119 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357AbbBXRra convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 12:47:30 -0500
Received: by iecrd18 with SMTP id rd18so34033224iec.8
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 09:47:30 -0800 (PST)
In-Reply-To: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24 February 2015 at 18:42, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com=
> wrote:
> diff --git a/drivers/net/phy/b53/Kconfig b/drivers/net/phy/b53/Kconfi=
g
> new file mode 100644
> index 0000000..21bf6e7
> --- /dev/null
> +++ b/drivers/net/phy/b53/Kconfig
> @@ -0,0 +1,12 @@
> +menuconfig B53
> +       tristate "Broadcom bcm53xx managed switch support"
> +       help
> +         This driver adds support for Broadcom managed switch chips.=
 It supports
> +         BCM5325E, BCM5365, BCM539x, BCM53115 and BCM53125 as well a=
s BCM63XX
> +         integrated switches.

- You forgot depends NET_SWITCHDEV
- I see, thanks, will do in V2
