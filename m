From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] caif-driver: Add CAIF-SPI Protocol driver.
Date: Fri, 25 Jun 2010 21:12:23 -0700 (PDT)
Message-ID: <20100625.211223.232914661.davem@davemloft.net>
References: <1277157484-29981-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjurbr@gmail.com, netdev@vger.kernel.org, marcel@holtmann.org,
	daniel.martensson@stericsson.com, linus.walleij@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40855
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750758Ab0FZEMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:12:10 -0400
In-Reply-To: <1277157484-29981-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Mon, 21 Jun 2010 23:58:04 +0200

> David Miller wrote:
>>You should never set CONFIG_* defines from the Makefile
>>commands, always set them in your Kconfig statements.
> 
> Changes from last version: Removed CONFIG_* defines from Makefile.

Surrounding a config options with "if XXX" protection is not the
proper way to protect config options.  Simply add a proper "Depends"
specification to it.
