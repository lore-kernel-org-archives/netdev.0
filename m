From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 3/4] tipc: safely copy UDP netlink data
 from user
Date: Sun, 06 Mar 2016 22:58:08 -0500 (EST)
Message-ID: <20160306.225808.1376970866333167103.davem@davemloft.net>
References: <1457011243-23605-1-git-send-email-richard.alpe@ericsson.com>
	<1457011243-23605-3-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbcCGD6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 22:58:09 -0500
In-Reply-To: <1457011243-23605-3-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Thu, 3 Mar 2016 14:20:42 +0100

> The netlink policy for TIPC_NLA_UDP_LOCAL and TIPC_NLA_UDP_REMOTE
> is of type binary with a defined length. This causes the policy
> framework to threat the defined length as maximum length.
> 
> There is however no protection against a user sending a smaller
> amount of data. Prior to this patch this wasn't handled which could
> result in a partially incomplete sockaddr_storage struct containing
> uninitialized data.
> 
> In this patch we use nla_memcpy() when copying the user data. This
> ensures a potential gap at the end is cleared out properly.
> 
> This was found by Julia with Coccinelle tool.
> 
> Reported-by: Daniel Borkmann <daniel@iogearbox.net>
> Reported-by: Julia Lawall <julia.lawall@lip6.fr>
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>
> Reviewed-by: Erik Hugne <erik.hugne@gmail.com>

Applied.
