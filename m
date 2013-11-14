From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix two race conditions in
 bond_store_updelay/downdelay
Date: Thu, 14 Nov 2013 16:29:44 -0500 (EST)
Message-ID: <20131114.162944.207243366387985452.davem@davemloft.net>
References: <1384358866-15157-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	vfalico@redhat.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755166Ab3KNV3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:29:46 -0500
In-Reply-To: <1384358866-15157-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Wed, 13 Nov 2013 17:07:46 +0100

> This patch fixes two race conditions between bond_store_updelay/downdelay
> and bond_store_miimon which could lead to division by zero as miimon can
> be set to 0 while either updelay/downdelay are being set and thus miss the
> zero check in the beginning, the zero div happens because updelay/downdelay
> are stored as new_value / bond->params.miimon. Use rtnl to synchronize with
> miimon setting.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Veaceslav Falico <vfalico@redhat.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied and queued up for -stable, thanks.
