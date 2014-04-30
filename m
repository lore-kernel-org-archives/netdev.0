From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: stmmac: set phy to use polling by default
Date: Wed, 30 Apr 2014 13:32:39 -0400 (EDT)
Message-ID: <20140430.133239.2011056068435013845.davem@davemloft.net>
References: <1398794181-17852-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, dinh.linux@gmail.com,
	netdev@vger.kernel.org, vbridger@altera.com
To: dinguyen@altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759256AbaD3Rck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 13:32:40 -0400
In-Reply-To: <1398794181-17852-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <dinguyen@altera.com>
Date: Tue, 29 Apr 2014 12:56:21 -0500

> From: Dinh Nguyen <dinguyen@altera.com>
> 
> mii_irq[] array is never initialized anywhere in the driver, thus mii_irq[]
> will always equate to zero. So, for the case where the PHY does not have an
> irq, we should use PHY_POLL for that situation.
> 
> Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
> Tested-by: Vince Bridgers <vbridger@altera.com>

Applied.
