From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8021q: fix a potential memory leak
Date: Sat, 21 Jun 2014 15:12:58 -0700 (PDT)
Message-ID: <20140621.151258.715350958253521786.davem@davemloft.net>
References: <1403070362-29664-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825AbaFUWM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 18:12:59 -0400
In-Reply-To: <1403070362-29664-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Wed, 18 Jun 2014 13:46:02 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> skb_cow called in vlan_reorder_header does not free the skb when it failed,
> and vlan_reorder_header returns NULL to reset original skb when it is called
> in vlan_untag, lead to a memory leak.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied and queued up for -stable, thanks.

And I agree with Eric that we could define this to return error codes
since 'skb' never changes so returning skb vs. NULL is rather awkward.
