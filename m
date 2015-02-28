From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] usbnet: Fix tx_packets stat for
 FLAG_MULTI_FRAME drivers
Date: Sat, 28 Feb 2015 14:28:01 -0500 (EST)
Message-ID: <20150228.142801.274701022130750604.davem@davemloft.net>
References: <1424979277.4444.39.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oliver@neukum.org,
	linux-kernel@codethink.co.uk, linux-usb@vger.kernel.org
To: ben.hutchings@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbbB1T2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 14:28:03 -0500
In-Reply-To: <1424979277.4444.39.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Date: Thu, 26 Feb 2015 19:34:37 +0000

> Currently the usbnet core does not update the tx_packets statistic for
> drivers with FLAG_MULTI_PACKET and there is no hook in the TX
> completion path where they could do this.
> 
> cdc_ncm and dependent drivers are bumping tx_packets stat on the
> transmit path while asix and sr9800 aren't updating it at all.
> 
> Add a packet count in struct skb_data so these drivers can fill it
> in, initialise it to 1 for other drivers, and add the packet count
> to the tx_packets statistic on completion.
> 
> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>

Applied, thanks Ben.
