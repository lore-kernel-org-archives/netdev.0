From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix broadcast wakeup contention after
 congestion
Date: Wed, 10 Dec 2014 14:46:00 -0500 (EST)
Message-ID: <20141210.144600.305925368750434533.davem@davemloft.net>
References: <1418201214-30767-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	erik.hugne@ericsson.com
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932739AbaLJTqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 14:46:03 -0500
In-Reply-To: <1418201214-30767-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <richard.alpe@ericsson.com>
Date: Wed, 10 Dec 2014 09:46:54 +0100

> From: Richard Alpe <richard.alpe@ericsson.com>
> 
> commit 908344cdda80 ("tipc: fix bug in multicast congestion handling")
> introduced a race in the broadcast link wakeup functionality.
> 
> This patch eliminates this broadcast link wakeup race caused by
> operation on the wakeup list without proper locking. If this race
> hit and corrupted the list all subsequent wakeup messages would be
> lost, resulting in a considerable memory leak.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>

Applied, thank you.
