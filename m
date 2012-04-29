From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] drivers/net/oki-semi: Donot recompute IP
 header checksum
Date: Sat, 28 Apr 2012 22:00:22 -0400 (EDT)
Message-ID: <20120428.220022.390443482939091529.davem@davemloft.net>
References: <1335510073-14018-1-git-send-email-roy.qing.li@gmail.com>
	<1335510073-14018-2-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822Ab2D2CAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 22:00:25 -0400
In-Reply-To: <1335510073-14018-2-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 27 Apr 2012 15:01:13 +0800

> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> If I understand correct, NETIF_F_IP_CSUM only means the hardware 
> will compute the TCP/UDP checksum, IP checksum is always computed 
> in software
> 
> So as a workround of hardware unable to compute small packages 
> checksum, do not need to compute IP header checksum.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>

Applied.
