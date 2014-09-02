From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: fix missing dependencies in
 NETFILTER_XT_TARGET_LOG
Date: Tue, 02 Sep 2014 14:00:11 -0700 (PDT)
Message-ID: <20140902.140011.1524495054200764419.davem@davemloft.net>
References: <1409660777-14999-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58578 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754439AbaIBVAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 17:00:12 -0400
In-Reply-To: <1409660777-14999-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue,  2 Sep 2014 14:26:17 +0200

> make defconfig reports:
> 
> warning: (NETFILTER_XT_TARGET_LOG) selects NF_LOG_IPV6 which has unmet direct dependencies (NET && INET && IPV6 && NETFILTER && NETFILTER_ADVANCED)
> 
> Fixes: d79a61d netfilter: NETFILTER_XT_TARGET_LOG selects NF_LOG_*
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied, thanks.
