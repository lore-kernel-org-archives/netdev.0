From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix a possible double free
Date: Tue, 20 Sep 2011 15:10:30 -0400 (EDT)
Message-ID: <20110920.151030.1978268649603302576.davem@davemloft.net>
References: <1316497936-16901-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, stable@kernel.org
To: rongqing.li@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095Ab1ITTMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 15:12:35 -0400
In-Reply-To: <1316497936-16901-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <rongqing.li@windriver.com>
Date: Tue, 20 Sep 2011 13:52:16 +0800

> From: Roy.Li <rongqing.li@windriver.com>
> 
> When calling snmp6_alloc_dev fails, the snmp6 relevant memory
> are freed by snmp6_alloc_dev. Calling in6_dev_finish_destroy
> will free these memory twice.
> 
> Double free will lead that undefined behavior occurs.
> 
> Signed-off-by: Roy.Li <rongqing.li@windriver.com>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks.
