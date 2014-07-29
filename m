From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bonding: fix a memory leak in bond_arp_send_all()
Date: Mon, 28 Jul 2014 17:28:21 -0700 (PDT)
Message-ID: <20140728.172821.1662975923710334910.davem@davemloft.net>
References: <20140725122121.GC528@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbaG2A2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 20:28:22 -0400
In-Reply-To: <20140725122121.GC528@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 25 Jul 2014 15:21:21 +0300

> This test is reversed so the memory is always leaked.  It's better style
> to remove the test anyway.
> 
> Fixes: 3e403a77779f ('bonding: make it possible to have unlimited nested upper vlans')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, but in the future please make "net-next" submissions explicit by saying
something like "[PATCH net-next] " in your subject.

Thanks.
