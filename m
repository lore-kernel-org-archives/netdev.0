From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] netpoll: add RCU annotation to npinfo field
Date: Mon, 28 Jan 2013 18:33:12 -0500 (EST)
Message-ID: <20130128.183312.1329934337917747204.davem@davemloft.net>
References: <1358926179-7168-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755457Ab3A1XdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 18:33:14 -0500
In-Reply-To: <1358926179-7168-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 23 Jan 2013 15:29:39 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> dev->npinfo is protected by RCU.
> 
> This fixes the following sparse warnings:
> 
> net/core/netpoll.c:177:48: error: incompatible types in comparison expression (different address spaces)
> net/core/netpoll.c:200:35: error: incompatible types in comparison expression (different address spaces)
> net/core/netpoll.c:221:35: error: incompatible types in comparison expression (different address spaces)
> net/core/netpoll.c:327:18: error: incompatible types in comparison expression (different address spaces)
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
