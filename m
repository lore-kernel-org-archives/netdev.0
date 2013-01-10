From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 2/2] Fix phy_attach - forward dev_flags for phy_attach
Date: Thu, 10 Jan 2013 15:40:36 +0100
Message-ID: <50EED2E4.80008@openwrt.org>
References: <1357819234-27752-1-git-send-email-konszert@marvell.com> <1357819234-27752-3-git-send-email-konszert@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, zertsekel@gmail.com, andrew@lunn.ch,
	benavi@marvell.com, linux-arm-kernel@lists.infradead.org,
	alior@marvell.com
To: Kosta Zertsekel <konszert@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:57230 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100Ab3AJOnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 09:43:10 -0500
Received: by mail-lb0-f173.google.com with SMTP id c1so540192lbg.32
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 06:43:08 -0800 (PST)
In-Reply-To: <1357819234-27752-3-git-send-email-konszert@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/10/13 13:00, Kosta Zertsekel a =C3=A9crit :
> Change-Id: Ie3191f95c36eada6d0c673460de5393641128182
> ---
>   drivers/net/ethernet/marvell/pxa168_eth.c | 2 +-
>   net/dsa/slave.c                           | 2 +-
>   2 files changed, 2 insertions(+), 2 deletions(-)

I think that you should have actually two patches, one for pxa168_eth=20
and one for net/dsa/slave.c.

Also, please prefix your patches with what was usually used on these=20
files before: "pxa168_eth:" and "net: dsa:" respectively.

By the way, most, if not all of the phy_connect() users in=20
drivers/net/ethernet/ also do not ensure they pass the phy device flags=
,=20
so you might want to fix this globally and not just for Marvell driver.

Thanks.
--
=46lorian
