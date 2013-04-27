From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] genetlink: fix possible memory leak in
 genl_family_rcv_msg()
Date: Fri, 26 Apr 2013 23:26:08 -0400 (EDT)
Message-ID: <20130426.232608.1636389400751636869.davem@davemloft.net>
References: <CAPgLHd_tU4suwLY9M1Xoq9osTMcFWMARAaQV=9eodCJ+hZLz-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, shemminger@vyatta.com, ebiederm@xmission.com,
	bhutchings@solarflare.com, pshelar@nicira.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658Ab3D0D0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 23:26:11 -0400
In-Reply-To: <CAPgLHd_tU4suwLY9M1Xoq9osTMcFWMARAaQV=9eodCJ+hZLz-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sat, 27 Apr 2013 09:34:16 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> 'attrbuf' is malloced in genl_family_rcv_msg() when family->maxattr &&
> family->parallel_ops, thus should be freed before leaving from the error
> handling cases, otherwise it will cause memory leak.
> 
> Introduced by commit def3117493eafd9dfa1f809d861e0031b2cc8a07
> (genl: Allow concurrent genl callbacks.)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
