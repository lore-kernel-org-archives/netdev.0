From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 v2] xfrm6: fix a potential use after free in
 xfrm6_policy.c
Date: Wed, 22 Oct 2014 15:39:00 -0400 (EDT)
Message-ID: <20141022.153900.831129482311515617.davem@davemloft.net>
References: <1413968993-13528-1-git-send-email-roy.qing.li@gmail.com>
	<1413968993-13528-2-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60872 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754331AbaJVTjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 15:39:02 -0400
In-Reply-To: <1413968993-13528-2-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Wed, 22 Oct 2014 17:09:53 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> pskb_may_pull() maybe change skb->data and make nh and exthdr pointer
> oboslete, so recompute the nd and exthdr
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
> Diff v1: add space between the date type and *, like (__be16 *)

Applied, thanks.
