From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: Let bridge not age 'externally'
 learnt FDB entries, they are removed when 'external' entity notifies the
 aging
Date: Wed, 04 Feb 2015 13:51:23 -0800 (PST)
Message-ID: <20150204.135123.1758781944610556479.davem@davemloft.net>
References: <1422897714-5956-1-git-send-email-siva.mannem.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: siva.mannem.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932593AbbBDVvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 16:51:25 -0500
In-Reply-To: <1422897714-5956-1-git-send-email-siva.mannem.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Mannem <siva.mannem.lnx@gmail.com>
Date: Mon,  2 Feb 2015 22:51:54 +0530

>  When 'learned_sync' flag is turned on, the offloaded switch
>  port syncs learned MAC addresses to bridge's FDB via switchdev notifier
>  (NETDEV_SWITCH_FDB_ADD). Currently, FDB entries learnt via this mechanism are
>  wrongly being deleted by bridge aging logic. This patch ensures that FDB
>  entries synced from offloaded switch ports are not deleted by bridging logic.
>  Such entries can only be deleted via switchdev notifier
>  (NETDEV_SWITCH_FDB_DEL).
> 
> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>

Applied, thanks.
