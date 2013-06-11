From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: pass correct parameter to
 skb_headers_offset_update()
Date: Tue, 11 Jun 2013 02:48:29 -0700 (PDT)
Message-ID: <20130611.024829.407999241720876122.davem@davemloft.net>
References: <fdf66733b5575423669ab215dbb7aea13fd82aeb.1370525076.git.panweiping3@gmail.com>
	<20130607064722.GF14972@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panweiping3@gmail.com, netdev@vger.kernel.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504Ab3FKJsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 05:48:30 -0400
In-Reply-To: <20130607064722.GF14972@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Fri, 7 Jun 2013 15:47:22 +0900

> On Thu, Jun 06, 2013 at 09:27:21PM +0800, Weiping Pan wrote:
>> Since commit 1a37e412a022(net: Use 16bits for *_headers fields of struct
>> skbuff), skb->*_header are relative to skb->head,
>> so copy_skb_header() should not call skb_headers_offset_update() now,
>> and we should pass correct parameter to skb_headers_offset_update() in
>> pskb_expand_head() and skb_copy_expand().
>> 
>> Signed-off-by: Weiping Pan <panweiping3@gmail.com>
> 
> Reviewed-by: Simon Horman <horms@verge.net.au>

Applied, thanks.
