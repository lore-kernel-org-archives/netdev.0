From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Check RTF_LOCAL on rt->rt6i_flags
 instead of rt->dst.flags
Date: Sun, 03 May 2015 21:50:00 -0400 (EDT)
Message-ID: <20150503.215000.151892544983821315.davem@davemloft.net>
References: <1430697949-3589092-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kernel-team@fb.com, tazaki@sfc.wide.ad.jp
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58349 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbEDBuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 21:50:05 -0400
In-Reply-To: <1430697949-3589092-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Sun, 3 May 2015 17:05:49 -0700

> In my earlier commit:
> 653437d02f1f ("ipv6: Stop /128 route from disappearing after pmtu update"),
> there was a horrible typo.  Instead of checking RTF_LOCAL on
> rt->rt6i_flags, it was checked on rt->dst.flags.  This patch fixes
> it.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Whoops, good catch, applied.

Thanks Martin.
