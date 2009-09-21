From: Andrew Victor <avictor.za@gmail.com>
Subject: Re: [PATCH 3/3] at91_can: add driver for Atmel's CAN controller on
	AT91SAM9263
Date: Mon, 21 Sep 2009 23:44:24 +0200
Message-ID: <cd73a99e0909211444x70af0b73k3db99d1ab379913f@mail.gmail.com>
References: <1253180254-11910-1-git-send-email-mkl@pengutronix.de>
	 <1253180254-11910-2-git-send-email-mkl@pengutronix.de>
	 <1253180254-11910-3-git-send-email-mkl@pengutronix.de>
	 <1253180254-11910-4-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Socketcan-core@lists.berlios.de,
	Andrew Victor <linux@maxim.org.za>, wg@grandegger.com
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:38517 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbZIUVoV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 17:44:21 -0400
Received: by fxm18 with SMTP id 18so381217fxm.17
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2009 14:44:24 -0700 (PDT)
In-Reply-To: <1253180254-11910-4-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi Marc,

> +static inline u32 at91_read(const struct at91_priv *priv, enum at91_=
reg reg)
> +{
> + =A0 =A0 =A0 return readl(priv->reg_base + reg);
> +}
> +
> +static inline void at91_write(const struct at91_priv *priv, enum at9=
1_reg reg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 value)
> +{
> + =A0 =A0 =A0 writel(value, priv->reg_base + reg);
> +}

Rather use __raw_readl() and __raw_writel().


Regards,
  Andrew Victor
