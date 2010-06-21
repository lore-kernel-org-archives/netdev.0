From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: Add CAIF-SPI Protocol driver.
Date: Sun, 20 Jun 2010 20:39:56 -0700 (PDT)
Message-ID: <20100620.203956.15250412.davem@davemloft.net>
References: <1276794164-20455-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjurbr@gmail.com, netdev@vger.kernel.org, marcel@holtmann.org,
	daniel.martensson@stericsson.com, linus.walleij@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46951
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757408Ab0FUDjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 23:39:44 -0400
In-Reply-To: <1276794164-20455-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Thu, 17 Jun 2010 19:02:44 +0200

> +ifeq ($(CONFIG_CAIF_SPI_SYNC),y)
> +CAIF_SPI_FLAGS := -DCONFIG_CAIF_SPI_SYNC
> +endif
> +

You should never set CONFIG_* defines from the Makefile
commands, always set them in your Kconfig statements.
