From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sky2: fix transmit DMA map leakage
Date: Wed, 03 Feb 2010 18:34:43 -0800 (PST)
Message-ID: <20100203.183443.101658649.davem@davemloft.net>
References: <20100201154147.5bb0b2c7@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, mbreuer@majjas.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53548
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751477Ab0BDCe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 21:34:29 -0500
In-Reply-To: <20100201154147.5bb0b2c7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 1 Feb 2010 15:41:47 -0800

> The book keeping structure for transmit always had the flags value
> cleared so transmit DMA maps were never released correctly.
> Based on patch by Jarek Poplawski, problem observed by Michael Breuer.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-2.6, and queued for -stable, thanks.
