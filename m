From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix CONFIG_SCTP_DBG_MSG=y null pointer
 dereference in sctp_v6_get_dst()
Date: Fri, 30 Nov 2012 12:21:46 -0500 (EST)
Message-ID: <20121130.122146.1137813662572852735.davem@davemloft.net>
References: <1354267062-15888-1-git-send-email-tt.rantala@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, vyasevich@gmail.com, sri@us.ibm.com,
	davej@redhat.com
To: tt.rantala@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933480Ab2K3RVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 12:21:48 -0500
In-Reply-To: <1354267062-15888-1-git-send-email-tt.rantala@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tommi Rantala <tt.rantala@gmail.com>
Date: Fri, 30 Nov 2012 11:17:42 +0200

> Trinity (the syscall fuzzer) triggered the following BUG, reproducible
> only when the kernel is configured with CONFIG_SCTP_DBG_MSG=y.
> 
> When CONFIG_SCTP_DBG_MSG is not set, the null pointer is never
> dereferenced.
 ...
> Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>

Applied, thanks.
