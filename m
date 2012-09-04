From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: use list_move_tail instead of
 list_del/list_add_tail
Date: Tue, 04 Sep 2012 14:16:37 -0400 (EDT)
Message-ID: <20120904.141637.1002775415545971280.davem@davemloft.net>
References: <CAPgLHd_w3-iAT66PW2i_jYyqmNrF-fKczcUEdBemPMvWX+fbOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, sri@us.ibm.com, yongjun_wei@trendmicro.com.cn,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132Ab2IDSQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 14:16:40 -0400
In-Reply-To: <CAPgLHd_w3-iAT66PW2i_jYyqmNrF-fKczcUEdBemPMvWX+fbOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 4 Sep 2012 17:58:16 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Using list_move_tail() instead of list_del() + list_add_tail().
> 
> spatch with a semantic match is used to found this problem.
> (http://coccinelle.lip6.fr/)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied to net-next, thank you.
