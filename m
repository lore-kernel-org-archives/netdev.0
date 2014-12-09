From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix missing spinlock init and nullptr
 oops
Date: Tue, 09 Dec 2014 13:42:09 -0500 (EST)
Message-ID: <20141209.134209.572446082511289348.davem@davemloft.net>
References: <1417622320-19730-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, ying.xue@windriver.com,
	richard.alpe@ericsson.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbaLISmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:42:12 -0500
In-Reply-To: <1417622320-19730-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Wed, 3 Dec 2014 16:58:40 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> commit 908344cdda80 ("tipc: fix bug in multicast congestion
> handling") introduced two bugs with the bclink wakeup
> function. This commit fixes the missing spinlock init for the
> waiting_sks list. We also eliminate the race condition
> between the waiting_sks length check/dequeue operations in
> tipc_bclink_wakeup_users by simply removing the redundant
> length check.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Acked-by: Tero Aho <Tero.Aho@coriant.com>

Applied.
