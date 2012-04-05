From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rps: introduce a new sysctl switch
 rps_workaround_buggy_driver
Date: Thu, 05 Apr 2012 06:44:12 -0400 (EDT)
Message-ID: <20120405.064412.2145338934095035978.davem@davemloft.net>
References: <4F7D7464.7040503@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raise.sail@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905Ab2DEKoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 06:44:18 -0400
In-Reply-To: <4F7D7464.7040503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yu <raise.sail@gmail.com>
Date: Thu, 05 Apr 2012 18:31:00 +0800

> 
> We encountered a buggy NIC driver or hardware/firmware, it keeps
> non-zero constant skb->rxhash for long time, so if we enabled RPS,
> the targeted CPU keeps same for long time too.
> 
> This patch introduces a sysctl switch to workaround for such problem,
> if the switch was on, RPS core discards the skb->rxhash that is
> computed by NIC hardware.
> 
> Hope this patch also can help others, thanks.
> 
> Signed-off-by Li Yu <bingtian.ly@taobao.com>

No way, we fix the drivers not add workarounds like this.
