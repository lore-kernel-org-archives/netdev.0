From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] gianfar: Fix gianfar select_queue bogosity
Date: Sat, 26 Dec 2009 20:25:39 -0800 (PST)
Message-ID: <20091226.202539.116393044.davem@davemloft.net>
References: <1261660386814-git-send-email-sandeep.kumar@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, galak@kernel.crashing.org,
	netdev@vger.kernel.org, yinghai@kernel.org, krkumar2@in.ibm.com
To: sandeep.kumar@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58523
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752208AbZL0EZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 23:25:39 -0500
In-Reply-To: <1261660386814-git-send-email-sandeep.kumar@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Gopalpet <sandeep.kumar@freescale.com>
Date: Thu, 24 Dec 2009 18:43:06 +0530

> From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
> 
> The gfar_select_queue() function was used to set queue mapping
> only for forwarding/bridging applications and the condition
> for locally generated packets was completely ignored.
> 
> The solution is to remove the gfar_select_queue() function and
> use skb_record_rx_queue to set queue mapping for
> forwarding/bridging applications. This will ensure that in case of
> forwarding/bridging applications txq = rxq will be selected and
> skb_tx_hash will be used to pick up a txq for locally generated packets.
> 
> Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>

Applied, thank you.
