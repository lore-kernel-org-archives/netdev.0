From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net/ethernet/micrel/ks8851_mll:
 Implement basic statistics
Date: Tue, 22 Jan 2013 20:51:32 -0500 (EST)
Message-ID: <20130122.205132.2281610193783011537.davem@davemloft.net>
References: <FD9AD8C5375B924CABC56D982DB3A802079D32D1@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ping.Doong@Micrel.Com
To: David.Choi@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836Ab3AWBvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 20:51:35 -0500
In-Reply-To: <FD9AD8C5375B924CABC56D982DB3A802079D32D1@EXMB1.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Choi, David" <David.Choi@Micrel.Com>
Date: Wed, 23 Jan 2013 01:40:41 +0000

> From: David J. Choi <david.choi@micrel.com>
>  
> Summary of changes:
>   add codes to collect basic statistical information about Ethernet packets.
>  
> Signed-off-by: David J. Choi <david.choi@micrel.com>

A Subject prefix of "ks8851_mll: " is sufficient, people who want the
whole patch name can simply look at the patch.

> +			if (frame_hdr->sts & RXFSHR_RXFV) 

This line has trailing whitespace errors.

> +				netdev->stats.rx_frame_errors++;
>  			pr_err("%s: err:skb alloc\n", __func__);

BTW it's inappropriate to log an SKB allocation failure as an error in
the kernel logs like this.  This can be completely normal on a heavily
loaded system.  People can look at the device statistics to learn about
this event, or use a more sophisticated tool like the drop monitor.
