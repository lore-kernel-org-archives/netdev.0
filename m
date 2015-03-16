From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: kernel socket should be released in
 init_net namespace
Date: Mon, 16 Mar 2015 16:25:25 -0400 (EDT)
Message-ID: <20150316.162525.1854410790143179678.davem@davemloft.net>
References: <1426501152-24764-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ebiederm@xmission.com
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbbCPUZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 16:25:27 -0400
In-Reply-To: <1426501152-24764-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Mon, 16 Mar 2015 18:19:12 +0800

> Creating a kernel socket with sock_create_kern() happens in "init_net"
> namespace, however, releasing it with sk_release_kernel() occurs in
> the current namespace which may be different with "init_net" namespace.
> Therefore, we should guarantee that the namespace in which a kernel
> socket is created is same as the socket is created.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks.
