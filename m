From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Don't check undefined error bits in RXBD
Date: Fri, 28 Feb 2014 17:16:56 -0500 (EST)
Message-ID: <20140228.171656.186518842453738150.davem@davemloft.net>
References: <1393628710-5476-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbaB1WQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 17:16:57 -0500
In-Reply-To: <1393628710-5476-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Fri, 28 Feb 2014 15:05:10 -0800

> Redefine the RXD_ERR_MASK to include only relevant error bits. This fixes
> a customer reported issue of randomly dropping packets on the 5719.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
> 
> Please consider adding this to -stable.

Applied and queued up for -stable, thanks Michael.
