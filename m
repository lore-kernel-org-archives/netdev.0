From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] taging: csr: fix the skb mac header reset
Date: Wed, 12 Jun 2013 00:22:47 -0700 (PDT)
Message-ID: <20130612.002247.1868683620537585681.davem@davemloft.net>
References: <1370589567-24043-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179Ab3FLHWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 03:22:48 -0400
In-Reply-To: <1370589567-24043-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri,  7 Jun 2013 15:19:27 +0800

> From: Li RongQing <roy.qing.li@gmail.com> 
> 
> mac_header can be offset if NET_SKBUFF_DATA_USES_OFFSET is set, so
> we should call skb_reset_mac_header to reset mac_header.
> 
> Or it will not work on net-next since "net: Use 16bits for *_headers
> fields of struct skbuff" commit is introduced.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Staging driver changes need to go through Greg KH.

Thanks.
