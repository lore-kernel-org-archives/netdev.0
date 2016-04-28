From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net] lan78xx: fix statistics counter error
Date: Thu, 28 Apr 2016 16:36:32 -0400 (EDT)
Message-ID: <20160428.163632.201946206552269744.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D408987F2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbcD1Ugf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:36:35 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D408987F2@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Mon, 25 Apr 2016 22:22:32 +0000

> From: Woojung Huh <woojung.huh@microchip.com>
> 
> Fix rx_bytes, tx_bytes and tx_frames error in netdev.stats.
> - rx_bytes counted bytes excluding size of struct ethhdr.
> - tx_packets didn't count multiple packets in a single urb
> - tx_bytes included 8 bytes of extra commands.
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Applied.
