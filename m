From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] avoid to hang up on sending since sysctl
 configuration overflow.
Date: Mon, 28 Jan 2013 23:16:23 -0500 (EST)
Message-ID: <20130128.231623.1606743073399806303.davem@davemloft.net>
References: <1359009328-24582-1-git-send-email-bingtian.ly@taobao.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	panweiping3@gmail.com, bingtian.ly@taobao.com
To: raise.sail@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51683 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031Ab3A2EQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 23:16:25 -0500
In-Reply-To: <1359009328-24582-1-git-send-email-bingtian.ly@taobao.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yu <raise.sail@gmail.com>
Date: Thu, 24 Jan 2013 14:35:28 +0800

> From: bingtian.ly@taobao.com
> 
>     I found if we write large than 4GB value to some sysctl variables,
> the sending syscall will hang up forever, because of these variables
> are 32 bits, such large value bring them overflow to 0 or negative.
> 
>     This patch try to fix overflow or prevent from zero value setup
> of below sysctl variables:
> 
> net.core.wmem_default
> net.core.rmem_default
> 
> net.core.rmem_max
> net.core.wmem_max
> 
> net.ipv4.udp_rmem_min
> net.ipv4.udp_wmem_min
> 
> net.ipv4.tcp_wmem
> net.ipv4.tcp_rmem
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Li Yu <raise.sail@gmail.com>

Applied, thanks.
