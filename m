From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: make neigh tables per netns
Date: Wed, 25 Jun 2014 16:33:49 -0700 (PDT)
Message-ID: <20140625.163349.1871889899393623750.davem@davemloft.net>
References: <1403561370-2876-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net,
	stephen@networkplumber.org, cwang@twopensource.com,
	ebiederm@xmission.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932388AbaFYXdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 19:33:50 -0400
In-Reply-To: <1403561370-2876-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 23 Jun 2014 15:09:30 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> Different net namespaces have different devices, routes, neighbours,
> so their neigh table should be separated as well. This patch makes
> gloable arp_tbl and nd_tbl etc. be per netns.
> 
> Also, as we don't support multiple tables per family, there is no
> point to make tables chained by linked list, they can just be
> statically compiled. This will eliminate the global neigh_tbl_lock.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: stephen hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Eric and any other networking namespace experts, please review this.

Thanks.
