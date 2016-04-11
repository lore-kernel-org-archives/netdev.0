From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Stop Rx Queues before freeing it up
Date: Mon, 11 Apr 2016 12:21:50 -0400 (EDT)
Message-ID: <20160411.122150.526042476363882773.davem@davemloft.net>
References: <1460353078-949-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799AbcDKQVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 12:21:52 -0400
In-Reply-To: <1460353078-949-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon, 11 Apr 2016 11:07:58 +0530

> Stop all Ethernet RX Queues before freeing up various Ingress/Egress
> Queues, etc. We were seeing cases of Ingress Queues not getting serviced
> during the shutdown process leading to Ingress Paths jamming up through
> the chip and blocking the shutdown effort itself.
> 
> One such case involved the Firmware sending a "Flush Token" through the
> ULP-TX -> ULP-RX path for an Ethernet TX Queue being freed in order to
> make sure there weren't any remaining TX Work Requests in the pipeline.
> But the return path was stalled by Ingress Data unable to be delivered to
> the Host because those Ingress Queues were no longer being serviced.
> 
> Based on original work by Casey Leedom <leedom@chelsio.com>
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thank you.
