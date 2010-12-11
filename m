From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] s2io: rx_ring_sz bounds checking
Date: Sat, 11 Dec 2010 11:47:31 -0800 (PST)
Message-ID: <20101211.114731.104061835.davem@davemloft.net>
References: <1292031604-16628-1-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sivakumar.subramani@exar.com,
	sreenivasa.honnur@exar.com, ram.vepa@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59226
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751330Ab0LKTrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 14:47:04 -0500
In-Reply-To: <1292031604-16628-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Fri, 10 Dec 2010 19:40:01 -0600

> modparm rx_ring_sz can be set to be greater than the maximum allowable
> number of blocks.  This results in an array overrun when probing the
> driver, and causes memory corruption.
> 
> Also, the MAX_RX_DESC_1 multiply the max number of rings by max number
> of blocker per ring by 127, but the driver does the same calculation
> with 127+1.  This results in the possibility of the value being set
> being larger than the maximum allowable value.
> 
> Finally, clean-up the s2io_ethtool_gringparam code to be more
> intuitive.
> 
> Signed-off-by: Jon Mason <jon.mason@exar.com>

Applied.
