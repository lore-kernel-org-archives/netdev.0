From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_conn_request: fix build error when
 IPv6 is disabled
Date: Sun, 29 Jun 2014 23:47:19 -0700 (PDT)
Message-ID: <20140629.234719.906236334351806800.davem@davemloft.net>
References: <1403979654-7738-1-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: octavian.purdila@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50178 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432AbaF3GrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 02:47:19 -0400
In-Reply-To: <1403979654-7738-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <octavian.purdila@intel.com>
Date: Sat, 28 Jun 2014 21:20:54 +0300

> Fixes build error introduced by commit 1fb6f159fd21c64 (tcp: add
> tcp_conn_request):
> 
> net/ipv4/tcp_input.c: In function 'pr_drop_req':
> net/ipv4/tcp_input.c:5889:130: error: 'struct sock_common' has no member named 'skc_v6_daddr'
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>

Applied, thanks.
