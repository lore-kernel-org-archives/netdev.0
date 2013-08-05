From: David Miller <davem@davemloft.net>
Subject: Re: [net-next,3/3] bonding: unwind on bond_add_vlan add failure
Date: Mon, 05 Aug 2013 16:09:46 -0700 (PDT)
Message-ID: <20130805.160946.1482696464133255516.davem@davemloft.net>
References: <1375709304-16778-4-git-send-email-nikolay@redhat.com>
	<20130805215921.GA14299@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab3HEXJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 19:09:46 -0400
In-Reply-To: <20130805215921.GA14299@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon, 5 Aug 2013 23:59:21 +0200

> On Mon, Aug 05, 2013 at 03:28:24PM +0200, nikolay@redhat.com wrote:
>>From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
>>
>>In case of bond_add_vlan() failure currently we'll have the vlan's
>>refcnt bumped up in all slaves, but it will never go down because it
>>failed to get added to the bond, so properly unwind the added vlan if
>>bond_add_vlan fails.
>>
>>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> In case patch 1/3 from series goes in... Otherwise I think it will be
> needed to patch bond_vlan_rx_add_vid().

I'm not happy with patch #1 and it needs more discussion between you
two.
