From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix dereference before check warning
Date: Thu, 14 Nov 2013 03:15:52 -0500 (EST)
Message-ID: <20131114.031552.1482448032176198856.davem@davemloft.net>
References: <1384331711-13707-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, paul.gortmaker@windriver.com,
	dan.carpenter@oracle.com, maloy@donjonn.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	ying.xue@windriver.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab3KNIPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 03:15:54 -0500
In-Reply-To: <1384331711-13707-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Wed, 13 Nov 2013 09:35:11 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> This fixes the following Smatch warning:
> net/tipc/link.c:2364 tipc_link_recv_fragment()
>     warn: variable dereferenced before check '*head' (see line 2361)
> 
> A null pointer might be passed to skb_try_coalesce if
> a malicious sender injects orphan fragments on a link.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>

Applied, thank you.
