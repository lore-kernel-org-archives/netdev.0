From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/13] tg3: Fix 5761 PXEboot crash
Date: Mon, 12 Nov 2007 21:07:13 -0800 (PST)
Message-ID: <20071112.210713.95371045.davem@davemloft.net>
References: <1194655117.5745.263.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48954
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750832AbXKMFHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:07:19 -0500
In-Reply-To: <1194655117.5745.263.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 09 Nov 2007 16:38:37 -0800

> When 5761 devices boot the machine using PXEboot, PXE leaves the device
> active when it terminates.  The tg3 driver has code to detect this
> condition and resets the device during initialization.  On 5761 devices,
> device resets involve sending a driver state update message to the APE
> on the 5761.  However, during this initialization stage, communications
> to the APE registers have not yet been set up.  The driver then
> dereferences a NULL pointer and crashes the machine.  The fix is to move
> the APE register access setup earlier in the initialization code to
> cover this condition.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Patch applied.
