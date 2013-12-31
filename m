From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] bonding: add lp_interval option
 support and simplify the code
Date: Tue, 31 Dec 2013 00:40:46 -0500 (EST)
Message-ID: <20131231.004046.2152145923402030558.davem@davemloft.net>
References: <52B537B3.3060504@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, vfalico@redhat.com,
	netdev@vger.kernel.org, sfeldma@cumulusnetworks.com
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099Ab3LaFks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 00:40:48 -0500
In-Reply-To: <52B537B3.3060504@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Sat, 21 Dec 2013 14:39:47 +0800

> The option lp_interval could only be set by sysfs, so add support for loading module.
> and update the Documentation/networking/bonding.txt for this option.
> 
> Use micro BOND_NO_USE_ARP to simplify the code for mode check.
> 
> v2: according to the networking coding style, the patch 01/03 need to cleanup the
>     style problem, thanks scott for his advice. The bond_check_param() have too
>     many duplicated code with bond sysfs, so I think when scott finish the bond_option_xxx_set(),
>     the bond_check_param() should be modify to use the bond_option_xxx_set() function
>     to simplify the code.

Series applied, thanks.
