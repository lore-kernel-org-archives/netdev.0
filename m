From: David Miller <davem@davemloft.net>
Subject: Re: [1/5][BNX2]: Fix netdev watchdog on 5708.
Date: Mon, 04 Jun 2007 21:21:54 -0700 (PDT)
Message-ID: <20070604.212154.94090289.davem@davemloft.net>
References: <1181001603.5275.12.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37141
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752330AbXFEEVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 00:21:41 -0400
In-Reply-To: <1181001603.5275.12.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 04 Jun 2007 17:00:03 -0700

> [BNX2]: Fix netdev watchdog on 5708.
> 
> There's a bug in the driver that only initializes half of the context
> memory on the 5708.  Surprisingly, this works most of the time except
> for some occasional netdev watchdogs when sending a lot of 64-byte
> packets.  The fix is to add the missing code to initialize the 2nd
> halves of all context memory.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
