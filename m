From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v2] net: sysctl: fix a kmemleak warning
Date: Fri, 23 Oct 2015 06:23:58 -0700 (PDT)
Message-ID: <20151023.062358.1394064585534232669.davem@davemloft.net>
References: <1445605189-1772-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbbJWNH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 09:07:29 -0400
In-Reply-To: <1445605189-1772-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 23 Oct 2015 20:59:49 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> the returned buffer of register_sysctl() is stored into net_header
> variable, but net_header is not used after, and compiler maybe
> optimise the variable out, and lead kmemleak reported the below warning
 ...
> Add the possible error handle to free the net_header to remove the
> kmemleak warning
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
