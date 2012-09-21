From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] l2tp: fix compile error when CONFIG_IPV6=m
 and CONFIG_L2TP=y
Date: Fri, 21 Sep 2012 12:07:08 -0400 (EDT)
Message-ID: <20120921.120708.2049925225953926043.davem@davemloft.net>
References: <1348209366-26978-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604Ab2IUQHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 12:07:16 -0400
In-Reply-To: <1348209366-26978-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri, 21 Sep 2012 14:36:06 +0800

> When CONFIG_IPV6=m and CONFIG_L2TP=y, I got the following compile error:
...
> This is due to l2tp uses symbols from IPV6, so when IPV6
> is a module, l2tp is not allowed to be builtin.
> 
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thanks.
