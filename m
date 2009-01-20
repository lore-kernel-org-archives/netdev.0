From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6] tg3: Fix firmware loading
Date: Mon, 19 Jan 2009 16:57:56 -0800 (PST)
Message-ID: <20090119.165756.163650913.davem@davemloft.net>
References: <1232397814.31530@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751884AbZATA5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 19:57:55 -0500
In-Reply-To: <1232397814.31530@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 19 Jan 2009 05:17:32 -0800

> This patch modifies how the tg3 driver handles device firmware.
> 
> The patch starts by consolidating David Woodhouse's earlier patch under
> the same name.  Specifically, the patch moves the request_firmware call
> into a separate tg3_request_firmware() function and calls that function
> from tg3_open() rather than tg3_init_one().
> 
> The patch then goes on to limit the number of devices that will make
> request_firmware calls.  The original firmware patch unnecessarily
> requested TSO firmware for devices that did not need it.  This patch
> reduces the set of devices making TSO firmware patches to approximately
> the following device set : 5703, 5704, and 5705.
> 
> Finally, the patch reduces the effects of a request_firmware() failure.
> For those devices that are requesting TSO firmware, the driver will turn
> off the TSO capability.  If TSO firmware becomes available at a later
> time, the device can be closed and then opened again to reacquire the
> TSO capability.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
