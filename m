From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] ethoc: Double check pending RX packet
Date: Wed, 24 Nov 2010 11:37:14 -0800 (PST)
Message-ID: <20101124.113714.232765158.davem@davemloft.net>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
	<1290606058-26703-6-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jonas@southpole.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33236
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755621Ab0KXTgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 14:36:49 -0500
In-Reply-To: <1290606058-26703-6-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Bonn <jonas@southpole.se>
Date: Wed, 24 Nov 2010 14:40:55 +0100

> An interrupt may occur between checking bd.stat and clearing the
> interrupt source register which would result in the packet going totally
> unnoticed as the interrupt will be missed.  Double check bd.stat after
> clearing the interrupt source register to guard against such an
> occurrence.
> 
> Signed-off-by: Jonas Bonn <jonas@southpole.se>
 ...
> +			if (bd.stat & RX_BD_EMPTY) 

Trailing whitespace.

> +				break;
> +
> +		}

Unnecessary empty line.
