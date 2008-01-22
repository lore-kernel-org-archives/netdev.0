From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 3/4][BNX2]: Add link-down workaround on 5706
 serdes.
Date: Mon, 21 Jan 2008 17:07:16 -0800 (PST)
Message-ID: <20080121.170716.52732223.davem@davemloft.net>
References: <1200964104.10010.48.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55111
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753072AbYAVBHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 20:07:10 -0500
In-Reply-To: <1200964104.10010.48.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 21 Jan 2008 17:08:24 -0800

> [BNX2]: Add link-down workaround on 5706 serdes.
> 
> In some blade systems using the 5706 serdes, the hardware sometimes
> does not properly generate link down interrupts.  We add a workaround
> in the driver's timer to force a link-down when some PHY registers
> report loss of SYNC.
> 
> The parallel detect logic is cleaned up slightly to better integrate
> the workaround.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
