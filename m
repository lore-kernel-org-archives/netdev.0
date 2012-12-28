From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] ah4/esp4: set transport header correctly for IPsec
 tunnel mode.
Date: Fri, 28 Dec 2012 15:22:56 -0800 (PST)
Message-ID: <20121228.152256.163682377977652704.davem@davemloft.net>
References: <1356682036-25642-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755116Ab2L1XW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 18:22:57 -0500
In-Reply-To: <1356682036-25642-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 28 Dec 2012 16:07:16 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> IPsec tunnel does not set ECN field to CE in inner header when
> the ECN field in the outer header is CE, and the ECN field in
> the inner header is ECT(0) or ECT(1).
> 
> The cause is ipip_hdr() does not return the correct address of
> inner header since skb->transport-header is not the inner header
> after esp_input_done2(), or ah_input().
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Likewise I'll leave this to Steffen.
