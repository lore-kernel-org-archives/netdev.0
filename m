From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ping: prevent NULL pointer dereference on write to
 msg_name
Date: Mon, 18 Nov 2013 16:02:38 -0500 (EST)
Message-ID: <20131118.160238.2288108703856396394.davem@davemloft.net>
References: <20131118060745.GL16541@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415Ab3KRVCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 16:02:41 -0500
In-Reply-To: <20131118060745.GL16541@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 18 Nov 2013 07:07:45 +0100

> A plain read() on a socket does set msg->msg_name to NULL. So check for
> NULL pointer first.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> 
> Addendum to "[v4] inet: prevent leakage of uninitialized memory to user in
> recv syscalls".

Applied and queued up for -stable, thanks Hannes.

Looks like ipv6 got this case right.
