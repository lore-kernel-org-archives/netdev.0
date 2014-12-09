From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix broadcast link wakeup after congestion
Date: Tue, 09 Dec 2014 16:03:45 -0500 (EST)
Message-ID: <20141209.160345.2146464767899198214.davem@davemloft.net>
References: <1417802360-5383-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	erik.hugne@ericsson.com
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbaLIVDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:03:47 -0500
In-Reply-To: <1417802360-5383-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <richard.alpe@ericsson.com>
Date: Fri, 5 Dec 2014 18:59:20 +0100

> From: Richard Alpe <richard.alpe@ericsson.com>
> 
> commit 908344cdda80 ("tipc: fix bug in multicast congestion
> handling") introduced two bugs in the bclink wakeup function.
> 
> This patch fixes the missing spinlock init for the broadcast link
> waiting_sks list and eliminates a broadcast link wakeup race caused
> by operation on the wakeup list without proper locking.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Acked-by: Tero Aho <Tero.Aho@coriant.com>

This patch does not apply to the current 'net' tree.
