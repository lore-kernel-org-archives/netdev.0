From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] net: Copy inner L3 and L4 headers as unaligned on
 GRE TEB
Date: Tue, 16 Feb 2016 15:25:25 -0500 (EST)
Message-ID: <20160216.152525.733686383348968748.davem@davemloft.net>
References: <20160209141234.19305.82202.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
	tom@herbertland.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753394AbcBPUZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:25:26 -0500
In-Reply-To: <20160209141234.19305.82202.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Tue, 09 Feb 2016 06:14:43 -0800

> This patch corrects the unaligned accesses seen on GRE TEB tunnels when
> generating hash keys.  Specifically what this patch does is make it so that
> we force the use of skb_copy_bits when the GRE inner headers will be
> unaligned due to NET_IP_ALIGNED being a non-zero value.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied and queued up for -stable, thanks Alex.
