From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next] net: macb: make magic-packet property generic
Date: Tue, 16 Feb 2016 10:12 +0100
Message-ID: <18886571.p5aYQgREQI@wuerfel>
References: <1455581638-27771-1-git-send-email-sergio.prado@e-labworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	nicolas.ferre@atmel.com, davem@davemloft.net,
	gregory.clement@free-electrons.com, narmstrong@baylibre.com,
	michal.simek@xilinx.com, harini.katakam@xilinx.com,
	boris.brezillon@free-electrons.com, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sergio Prado <sergio.prado@e-labworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:64112 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754621AbcBPJM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 04:12:29 -0500
In-Reply-To: <1455581638-27771-1-git-send-email-sergio.prado@e-labworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 15 February 2016 22:13:58 Sergio Prado wrote:
> Signed-off-by: Sergio Prado <sergio.prado@e-labworks.com>
> ---
> As requested by Rob Herring on patch
> https://patchwork.ozlabs.org/patch/580862/
> 

This needs a changelog comment, at least clarify that the existing
value has never been used in production, so we are not breaking
anything with the incompatible binding  change.

	Arnd
