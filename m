From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: fix error return code in rtnl_link_fill()
Date: Wed, 27 Mar 2013 14:10:31 -0400 (EDT)
Message-ID: <20130327.141031.905737406648181970.davem@davemloft.net>
References: <CAPgLHd8F8-uRfAi4R=xqHa76X8N9P+-UosF-6zC=OXStKbcP-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, jiri@resnulli.us, edumazet@google.com,
	vyasevic@redhat.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279Ab3C0SKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 14:10:34 -0400
In-Reply-To: <CAPgLHd8F8-uRfAi4R=xqHa76X8N9P+-UosF-6zC=OXStKbcP-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 27 Mar 2013 21:22:45 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the error handling case
> instead of 0(possible overwrite to 0 by ops->fill_xstats call),
> as returned elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
