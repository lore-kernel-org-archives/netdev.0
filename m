From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fib_semantics: increment fib_info_cnt after
 fib_info allocation
Date: Wed, 07 May 2014 17:15:06 -0400 (EDT)
Message-ID: <20140507.171506.289552938622558058.davem@davemloft.net>
References: <1399389788-20363-1-git-send-email-popovich_sergei@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: popovich_sergei@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbaEGVPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 17:15:08 -0400
In-Reply-To: <1399389788-20363-1-git-send-email-popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ru>
Date: Tue,  6 May 2014 18:23:08 +0300

> Increment fib_info_cnt in fib_create_info() right after successfuly
> alllocating fib_info structure, overwise fib_metrics allocation failure
> leads to fib_info_cnt incorrectly decremented in free_fib_info(), called
> on error path from fib_create_info().
> 
> Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>

Applied and queued up for -stable, thanks Sergey.
