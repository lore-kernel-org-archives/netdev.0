From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] connector: remove lazy workqueue creation
Date: Sun, 24 Oct 2010 14:21:34 -0700 (PDT)
Message-ID: <20101024.142134.226785854.davem@davemloft.net>
References: <4CB8250A.7040902@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, netdev@vger.kernel.org, fweisbec@gmail.com
To: tj@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33164
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932428Ab0JXVVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 17:21:12 -0400
In-Reply-To: <4CB8250A.7040902@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tejun Heo <tj@kernel.org>
Date: Fri, 15 Oct 2010 11:55:22 +0200

> Commit 1a5645bc (connector: create connector workqueue only while
> needed once) implements lazy workqueue creation for connector
> workqueue.  With cmwq now in place, lazy workqueue creation doesn't
> make much sense while adding a lot of complexity.  Remove it and
> allocate an ordered workqueue during initialization.
> 
> This also removes a call to flush_scheduled_work() which is deprecated
> and scheduled to be removed.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Applied, thank you.
