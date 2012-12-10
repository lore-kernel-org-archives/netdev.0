From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Allow DCBnl to use other namespaces besides
 init_net
Date: Mon, 10 Dec 2012 14:09:46 -0500 (EST)
Message-ID: <20121210.140946.2049286516117233850.davem@davemloft.net>
References: <20121210064813.10883.88194.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570Ab2LJTJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 14:09:49 -0500
In-Reply-To: <20121210064813.10883.88194.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Sun, 09 Dec 2012 22:48:13 -0800

> Allow DCB and net namespace to work together. This is useful if you
> have containers that are bound to 'phys' interfaces that want to
> also manage their DCB attributes.
> 
> The net namespace is taken from sock_net(skb->sk) of the netlink skb.
> 
> CC: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
