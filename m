From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: fix error return code in fw_change_attrs()
Date: Fri, 19 Apr 2013 17:35:26 -0400 (EDT)
Message-ID: <20130419.173526.829927804716362622.davem@davemloft.net>
References: <CAPgLHd-cDj8j3tKofRMwJ8GE39LkO8ZvtTJ34aSFDSHO+7GjnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48575 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933914Ab3DSVf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 17:35:29 -0400
In-Reply-To: <CAPgLHd-cDj8j3tKofRMwJ8GE39LkO8ZvtTJ34aSFDSHO+7GjnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 18 Apr 2013 10:49:10 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return -EINVAL when tb[TCA_FW_MASK] is set and head->mask != 0xFFFFFFFF
> instead of 0 (ifdef CONFIG_NET_CLS_IND and tb[TCA_FW_INDEV]), as done elsewhere
> in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
