From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] bgmac: register MII bus
Date: Thu, 07 Mar 2013 12:45:34 +0100
Message-ID: <51387DDE.7040302@openwrt.org>
References: <1362656523-23081-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:34037 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932633Ab3CGLtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 06:49:00 -0500
Received: by mail-ee0-f51.google.com with SMTP id d17so220351eek.24
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 03:48:59 -0800 (PST)
In-Reply-To: <1362656523-23081-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Rafal,

On 03/07/2013 12:42 PM, Rafa=C5=82 Mi=C5=82ecki wrote:
>
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> ---

This looking good, just one nitpick.

[snip]

> +
> +	mii_bus->irq =3D kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);

You can use kmalloc_array(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL) here
--
=46lorian
