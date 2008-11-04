From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/15] tg3: Preserve DASH connectivity when WOL enabled
Date: Mon, 03 Nov 2008 16:51:19 -0800 (PST)
Message-ID: <20081103.165119.244108370.davem@davemloft.net>
References: <1225751619.6172@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38249
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753444AbYKDAvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 19:51:43 -0500
In-Reply-To: <1225751619.6172@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 3 Nov 2008 02:10:57 -0800

> DASH firmware runs on the APE side of the chip, but it requires a few MAC
> to be programmed correctly.
> 
> When WOL is enabled and management firmware is disabled, incoming
> packets are evaluated and discarded at the chip's rule processor.
> When management firmware is enabled, the hardware must be informed that
> there are agents further up the stack that still use the incoming
> frames.  Normally management firmware will configure the MAC correctly
> on its own, but there can be cases where the setting could get clobbered
> by the driver.  The first hunk of this patch preserves this setting.
> 
> The second hunk of this patch wipes out the driver present signature of
> the APE memory space.  By doing so, the DASH firmware can assume
> driver absent behavior.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
