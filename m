From: David Miller <davem@davemloft.net>
Subject: Re: Pull request for 'davem-next.base_addr.removal' branch
Date: Sat, 07 Apr 2012 09:28:35 -0400 (EDT)
Message-ID: <20120407.092835.1375353252765830240.davem@davemloft.net>
References: <20120407102051.GA5551@electric-eye.fr.zoreil.com>
	<20120407.085012.658444364459389098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com, andy@greyhouse.net,
	chris.snook@gmail.com, venza@brownhat.org, DavidLv@viatech.com.cn,
	grantgrundler@gmail.com, ionut@badula.org, jcliburn@gmail.com,
	jdmason@kudzu.us, mason@myri.com, mchan@broadcom.com,
	stas.yakovlev@gmail.com, steve.glendinning@smsc.com,
	thockin@hockin.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866Ab2DGNa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2012 09:30:56 -0400
In-Reply-To: <20120407.085012.658444364459389098.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 07 Apr 2012 08:50:12 -0400 (EDT)

> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Sat, 7 Apr 2012 12:20:51 +0200
> 
>> Please pull from branch 'davem-next.base_addr.removal' in repository
>> 
>> git://violet.fr.zoreil.com/romieu/linux davem-next.base_addr.removal
>> 
>> to get the changes below.
> 
> Pulled, thanks for doing this work Francois.

I had to add the following patch to fix a warning:

--------------------
fealnx: Remove unused local label 'out' in netdev_open().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/fealnx.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index 6f939a1..9d71c9c 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -923,7 +923,6 @@ static int netdev_open(struct net_device *dev)
 	np->reset_timer.data = (unsigned long) dev;
 	np->reset_timer.function = reset_timer;
 	np->reset_timer_armed = 0;
-out:
 	return rc;
 }
 
-- 
1.7.7.6
