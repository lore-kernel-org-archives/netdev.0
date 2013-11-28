From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] bonding: disable arp and enable mii monitoring
 when bond change to no uses arp mode
Date: Thu, 28 Nov 2013 18:20:49 -0500 (EST)
Message-ID: <20131128.182049.1314421032838540772.davem@davemloft.net>
References: <1384815032.4774.55.camel@dcbw.foobar.com>
	<528ACD8A.1010409@greyhouse.net>
	<528F6A1B.70904@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, dcbw@redhat.com, fubar@us.ibm.com,
	nikolay@redhat.com, vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47337 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab3K1XUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 18:20:51 -0500
In-Reply-To: <528F6A1B.70904@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Fri, 22 Nov 2013 22:28:43 +0800

> Because the ARP monitoring is not support for 802.3ad, but I still
> could change the mode to 802.3ad from ab mode while ARP monitoring
> is running, it is incorrect.
> 
> So add a check for 802.3ad in bonding_store_mode to fix the problem,
> and make a new macro BOND_NO_USES_ARP() to simplify the code.
> 
> v2: according to the Dan Williams's suggestion, bond mode is the most
>     important bond option, it should override any of the other sub-options.
>     So when the mode is changed, the conficting values should be cleared
>     or reset, otherwise the user has to duplicate more operations to modify
>     the logic. I disable the arp and enable mii monitoring when the bond mode
>     is changed to AB, TB and 8023AD if the arp interval is true.
> 
> v3: according to the Nik's suggestion, the default value of miimon should need
>     a name, there is several place to use it, and the bond_store_arp_interval()
>     could use micro BOND_NO_USES_ARP to make the code more simpify.
> 
> Suggested-by: Dan Williams <dcbw@redhat.com>
> Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied, thanks for following up on this Ding.
