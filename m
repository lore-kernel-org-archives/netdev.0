From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] bonding: add port protection for
 bond_3ad_xxx_change()
Date: Wed, 18 Dec 2013 16:53:20 -0500 (EST)
Message-ID: <20131218.165320.513139543099757450.davem@davemloft.net>
References: <52AAD36B.40103@huawei.com>
	<28416.1386973562@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, andy@greyhouse.net, vfalico@redhat.com,
	netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753945Ab3LRVxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 16:53:25 -0500
In-Reply-To: <28416.1386973562@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 13 Dec 2013 14:26:02 -0800

> Ding Tianhong <dingtianhong@huawei.com> wrote:
> 
>>Jay Vosburgh said that the bond_3ad_adapter_speed_changed and 
>>bond_3ad_adapter_duplex_changed is called with RTNL only, and
>>the functions will modify the port's information with no further
>>locking, they will not mutex against bond state machine and
>>incoming LACPDU which do not hold RTNL, So I add port lock to
>>protect the port information.
>>
>>But they are not critical bugs, they exist since day one, and till
>>now they have never been hit and reported, because change for speed
>>and duplex is very rare, and will not occur critical problem.
>>
>>The comments in the function is very old, cleanup the comments together.
> 
> 	For entire series:
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Series applied, thanks.
