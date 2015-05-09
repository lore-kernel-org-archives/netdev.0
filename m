From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] gianfar: Enable changing mac addr when if
 up
Date: Sat, 09 May 2015 17:38:02 -0400 (EDT)
Message-ID: <20150509.173802.236852068324361392.davem@davemloft.net>
References: <1430924850-2871-1-git-send-email-claudiu.manoil@freescale.com>
	<1430924850-2871-2-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975AbbEIViD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 17:38:03 -0400
In-Reply-To: <1430924850-2871-2-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Wed, 6 May 2015 18:07:30 +0300

> Use device flag IFF_LIVE_ADDR_CHANGE to signal that
> the device supports changing the hardware address when
> the device is running.
> This allows eth_mac_addr() to change the mac address
> also when the network device's interface is open.
> This capability is required by certain applications,
> like bonding mode 6 (Adaptive Load Balancing).
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied.
