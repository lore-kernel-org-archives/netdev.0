From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/2] net_sched: make dev_trans_start return
 vlan's real dev trans_start
Date: Mon, 05 Aug 2013 12:18:35 -0700 (PDT)
Message-ID: <20130805.121835.1820823163671920500.davem@davemloft.net>
References: <1375560467-1604-1-git-send-email-nikolay@redhat.com>
	<1375560467-1604-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@redhat.com, fubar@us.ibm.com,
	jhs@mojatatu.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48357 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754613Ab3HETSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 15:18:36 -0400
In-Reply-To: <1375560467-1604-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Sat,  3 Aug 2013 22:07:47 +0200

> From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
> 
> Vlan devices are LLTX and don't update their own trans_start, so if
> dev_trans_start has to be called with a vlan device then 0 or a stale
> value will be returned. Currently the bonding is the only such user, and
> it's needed for proper arp monitoring when the slaves are vlans.
> Fix this by extracting the vlan's real device trans_start.
> 
> Suggested-by: David Miller <davem@davemloft.net>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied.
