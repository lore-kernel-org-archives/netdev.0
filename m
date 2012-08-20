From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] netconsole: remove a redundant netconsole_target_put()
Date: Mon, 20 Aug 2012 03:00:32 -0700 (PDT)
Message-ID: <20120820.030032.626018195082995969.davem@davemloft.net>
References: <1345309340-15499-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448Ab2HTKAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 06:00:33 -0400
In-Reply-To: <1345309340-15499-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Sun, 19 Aug 2012 01:02:20 +0800

> This netconsole_target_put() is obviously redundant, and it
> causes a kernel segfault when removing a bridge device which has
> netconsole running on it.
> 
> This is caused by:
> 
> 	commit 8d8fc29d02a33e4bd5f4fa47823c1fd386346093
> 	Author: Amerigo Wang <amwang@redhat.com>
> 	Date:   Thu May 19 21:39:10 2011 +0000
> 
> 	    netpoll: disable netpoll when enslave a device
> 
> Cc: David Miller <davem@davemloft.net>
>  (for all 3.x stable releases)
> Cc: stable@vger.kernel.org
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thanks.
