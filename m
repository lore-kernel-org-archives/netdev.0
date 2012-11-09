From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: remove rt6i_peer_genid from rt6_info
 and its handler
Date: Thu, 08 Nov 2012 21:30:07 -0500 (EST)
Message-ID: <20121108.213007.908674593033769865.davem@davemloft.net>
References: <1352361393-4807-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756523Ab2KICaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 21:30:23 -0500
In-Reply-To: <1352361393-4807-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu,  8 Nov 2012 15:56:33 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> 6431cbc25f(Create a mechanism for upward inetpeer propagation into routes)
> introduces these codes, but this mechanism is never enabled since
> rt6i_peer_genid always is zero whether it is not assigned or assigned by
> rt6_peer_genid(). After 5943634fc5 (ipv4: Maintain redirect and PMTU info
> in struct rtable again), the ipv4 related codes of this mechanism has been
> removed, I think we maybe able to remove them now.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
