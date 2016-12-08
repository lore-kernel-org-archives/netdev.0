From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] icmp: correct return value of icmp_rcv()
Date: Thu, 08 Dec 2016 11:24:53 -0500 (EST)
Message-ID: <20161208.112453.569765817704988921.davem@davemloft.net>
References: <1481093573-5123-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33830 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932981AbcLHQY5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 11:24:57 -0500
In-Reply-To: <1481093573-5123-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Wed,  7 Dec 2016 14:52:53 +0800

> Currently, icmp_rcv() always return zero on a packet delivery upcall.
> 
> To make its behavior more compliant with the way this API should be
> used, this patch changes this to let it return NET_RX_SUCCESS when the
> packet is proper handled, and NET_RX_DROP otherwise.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied.
