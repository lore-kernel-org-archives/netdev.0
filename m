From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/15] tg3: Refine power management and WOL code
Date: Mon, 03 Nov 2008 16:53:55 -0800 (PST)
Message-ID: <20081103.165355.142594798.davem@davemloft.net>
References: <1225751625.6187@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38269
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752918AbYKDAyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 19:54:19 -0500
In-Reply-To: <1225751625.6187@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 3 Nov 2008 02:13:10 -0800

> Commit 12dac0756d357325b107fe6ec24921ec38661839 introduced the new PCI
> PM API to the tg3 driver.  The patch was understandably conservative, so
> this patch elaborates on that work.
> 
> The patch starts by creating a single point in tg3_set_power_state()
> to decide whether or not to enable WOL.  The rest of the code in
> tg3_set_power_state() was then pivoted to use the result of this
> decision.
> 
> The patch then makes sure the device is allowed to wakeup before
> reporting whether or not WOL is currently enabled.  The final hunks of
> the patch consolidate where the WOL capability and WOL enabled flags
> are set to a single location.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
