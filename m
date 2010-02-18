From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_UNIX: update locking comment
Date: Thu, 18 Feb 2010 14:12:13 -0800 (PST)
Message-ID: <20100218.141213.208353070.davem@davemloft.net>
References: <20100218093423.52165efd@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50850
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758251Ab0BRWL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 17:11:57 -0500
In-Reply-To: <20100218093423.52165efd@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 18 Feb 2010 09:34:23 -0800

> The lock used in unix_state_lock() is a spin_lock not reader-writer.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
