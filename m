From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IrDA] KingSun/DonShine USB IrDA dongle support
Date: Wed, 09 May 2007 16:18:34 -0700 (PDT)
Message-ID: <20070509.161834.97294601.davem@davemloft.net>
References: <20070509224027.GA4458@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	a_villacis@palosanto.com
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60040
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754891AbXEIXSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 19:18:36 -0400
In-Reply-To: <20070509224027.GA4458@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Thu, 10 May 2007 01:40:27 +0300

> From: Alex Villac$,3u=(Bs Lasso <a_villacis@palosanto.com>
> 
> This dongle does not follow the usb-irda specification, so it needs its
> own special driver. In addition, it uses interrupt endpoints instead of
> bulk ones as the rest of USB IrDA dongles supported by Linux (just to be
> different?) and data reads need to be parsed to extract the valid bytes
> before being unwrapped (details in the comment at the start of the
> source). No speed commands have been discovered for this dongle, and I
> suspect it does not have any at all.
> 
> On plugin, this dongle reports vendor and device IDs: 0x07c0:0x4200 .
> 
> The Windows driver that is used normally to control this dongle has a
> filename of DSIR620.SYS .
> 
> Signed-off-by: Alex Villac$,3u=(Bs Lasso <a_villacis@palosanto.com>
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied, thanks a lot.
