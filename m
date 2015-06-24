From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip: report the original address of ICMP messages
Date: Wed, 24 Jun 2015 00:49:05 -0700 (PDT)
Message-ID: <20150624.004905.1014922699905948754.davem@davemloft.net>
References: <1435037679-2304-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbbFXHhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 03:37:13 -0400
In-Reply-To: <1435037679-2304-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Tue, 23 Jun 2015 08:34:39 +0300

> ICMP messages can trigger ICMP and local errors. In this case
> serr->port is 0 and starting from Linux 4.0 we do not return
> the original target address to the error queue readers.
> Add function to define which errors provide addr_offset.
> With this fix my ping command is not silent anymore.
> 
> Fixes: c247f0534cc5 ("ip: fix error queue empty skb handling")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied and queued up for -stable, thanks.
