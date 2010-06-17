From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: fdb cleanup runs too often
Date: Thu, 17 Jun 2010 13:55:54 -0700 (PDT)
Message-ID: <20100617.135554.39173816.davem@davemloft.net>
References: <20100615091412.17e0d656@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54777
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760749Ab0FQUzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 16:55:44 -0400
In-Reply-To: <20100615091412.17e0d656@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 15 Jun 2010 09:14:12 -0700

> 
> It is common in end-node, non STP bridges to set forwarding
> delay to zero; which causes the forwarding database cleanup
> to run every clock tick. Change to run only as soon as needed
> or at next ageing timer interval which ever is sooner.
> 
> Use round_jiffies_up macro rather than attempting round up
> by changing value.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied and queued up for -stable, thanks.
