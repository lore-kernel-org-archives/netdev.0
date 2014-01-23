From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] bonding: fix primary problem for
 bonding
Date: Wed, 22 Jan 2014 17:46:26 -0800 (PST)
Message-ID: <20140122.174626.1807653611284621368.davem@davemloft.net>
References: <52DA3B3F.5090004@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbaAWBq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 20:46:27 -0500
In-Reply-To: <52DA3B3F.5090004@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Sat, 18 Jan 2014 16:28:47 +0800

> If the slave's name changed, and the bond params primary is exist,
> the bond should deal with the situation in two ways:
> 
> 1) If the slave was the primary slave yet, clean the primary slave
>    and reselect active slave.
> 2) If the slave's new name is as same as bond primary, set the slave
>    as primary slave and reselect active slave.
> 
> If the new primary is not matching any slave in the bond, the bond should
> record it to params, clean the primary slave and select a new active slave.
> 
> Update bonding.txt for primary description.

Series applied, thanks.
