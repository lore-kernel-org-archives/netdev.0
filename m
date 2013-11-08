From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] nfnetlink: do not ack malformed messages
Date: Fri, 08 Nov 2013 15:12:36 -0500 (EST)
Message-ID: <20131108.151236.742989177948419719.davem@davemloft.net>
References: <fa44451df8aa56773b1b17cbbd86ced8b54eca5a.1383850681.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, pmatouse@redhat.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757551Ab3KHUMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 15:12:39 -0500
In-Reply-To: <fa44451df8aa56773b1b17cbbd86ced8b54eca5a.1383850681.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu,  7 Nov 2013 19:59:19 +0100

> Commit 0628b123c96d ("netfilter: nfnetlink: add batch support and use it
> from nf_tables") introduced a bug leading to various crashes in netlink_ack
> when netlink message with invalid nlmsg_len was sent by an unprivileged
> user.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

This is obvious enough that I'm going to apply it directly, I hope Pablo
does not mind.

Thanks!
