From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Fix incorrect memcpy source memory
Date: Wed, 25 May 2016 21:43:56 -0700 (PDT)
Message-ID: <20160525.214356.1035437797033559058.davem@davemloft.net>
References: <1464216023-6428-1-git-send-email-marex@denx.de>
	<20160526002625.GE21924@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marex@denx.de, netdev@vger.kernel.org, peppe.cavallaro@st.com,
	alexandre.torgue@st.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbcEZEoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 00:44:00 -0400
In-Reply-To: <20160526002625.GE21924@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu, 26 May 2016 02:26:25 +0200

> On Thu, May 26, 2016 at 12:40:23AM +0200, Marek Vasut wrote:
>> The memcpy() currently copies mdio_bus_data into new_bus->irq, which
>> makes no sense, since the mdio_bus_data structure contains more than
>> just irqs. The code was likely supposed to copy mdio_bus_data->irqs
>> into the new_bus->irq instead, so fix this.
>> 
>> Signed-off-by: Marek Vasut <marex@denx.de>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> Cc: Alexandre Torgue <alexandre.torgue@st.com>
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Applied and queued up for -stable, thanks.
