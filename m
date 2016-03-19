From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: removes duplicate skb_mark_napi_id() calls.
Date: Fri, 18 Mar 2016 22:21:50 -0400 (EDT)
Message-ID: <20160318.222150.1424324448492389739.davem@davemloft.net>
References: <20160316170450.GA30365@jwg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weongyo.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbcCSCVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 22:21:52 -0400
In-Reply-To: <20160316170450.GA30365@jwg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weongyo Jeong <weongyo.linux@gmail.com>
Date: Wed, 16 Mar 2016 10:04:53 -0700

> Because napi_gro_receive() function calls skb_mark_napi_id() function,
> it doesn't need to set it twice.
> 
> Signed-off-by: Weongyo Jeong <weongyo.linux@gmail.com>

Unless you can show a significant performance argument, or other
significant improvement resulting from this patch, I am not applying
it.
