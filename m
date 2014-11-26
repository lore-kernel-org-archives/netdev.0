From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 1/1] ipv6: Remove unnecessary test
Date: Wed, 26 Nov 2014 12:27:37 -0500 (EST)
Message-ID: <20141126.122737.294202168447173855.davem@davemloft.net>
References: <1416968758-19641-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yanjun.Zhu@windriver.com,
	honkiko@gmail.com, opurdila@ixiacom.com, xemul@openvz.org,
	cwang@twopensource.com
To: zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbaKZR1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 12:27:39 -0500
In-Reply-To: <1416968758-19641-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>
Date: Wed, 26 Nov 2014 10:25:58 +0800

> The "init_net" test in function addrconf_exit_net is introduced
> in commit 44a6bd29 [Create ipv6 devconf-s for namespaces] to avoid freeing
> init_net. In commit c900a800 [ipv6: fix bad free of addrconf_init_net],
> function addrconf_init_net will allocate memory for every net regardless of
> init_net. In this case, it is unnecessary to make "init_net" test.
> 
> CC: Hong Zhiguo <honkiko@gmail.com>
> CC: Octavian Purdila <opurdila@ixiacom.com>
> CC: Pavel Emelyanov <xemul@openvz.org>
> CC: Cong Wang <cwang@twopensource.com>
> Suggested-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>

Applied, thanks.
