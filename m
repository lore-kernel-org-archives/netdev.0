From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH][v3] mdio-mux-gpio: Use GPIO descriptor interface and new
 gpiod_set_array function
Date: Fri, 28 Nov 2014 16:56:08 +0100
Message-ID: <CACRpkdbUZ309SCh2bJD_q5wieNZyRPsGjyUS+-g_Yxg13SPc5A@mail.gmail.com>
References: <1581158.UhESICdgeM@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Daney <david.daney@cavium.com>
To: Rojhalat Ibrahim <imr@rtschenk.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:51137 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbaK1P4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 10:56:08 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn15so5867262igb.15
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 07:56:08 -0800 (PST)
In-Reply-To: <1581158.UhESICdgeM@pcimr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 2:57 PM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:

> Convert mdio-mux-gpio to the GPIO descriptor interface and use the new
> gpiod_set_array function to set all output signals simultaneously.
>
> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> Acked-by: David S. Miller <davem@davemloft.net>
> --
> This patch depends on the gpiod_set_array function, which is available in
> the linux-gpio devel tree.
>
> Change log:
>   v3: remove unnecessary braces
>   v2: fix gpiod_get_index usage

I already merged v2 and removed the braces myself.

Yours,
Linus Walleij
