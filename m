From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] bonding: don't use stale speed and duplex
 information
Date: Thu, 18 Feb 2016 15:27:11 -0500 (EST)
Message-ID: <20160218.152711.37460017116970297.davem@davemloft.net>
References: <25869.1454962202@famine>
	<20160216.151448.1415574551982584505.davem@davemloft.net>
	<17965.1455827152@famine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, emil.s.tantilov@intel.com,
	zyjzyj2000@gmail.com, vfalico@gmail.com, dingtianhong@huawei.com,
	gospo@cumulusnetworks.com
To: jay.vosburgh@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1426732AbcBRU1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 15:27:14 -0500
In-Reply-To: <17965.1455827152@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <jay.vosburgh@canonical.com>
Date: Thu, 18 Feb 2016 12:25:52 -0800

> David Miller <davem@davemloft.net> wrote:
> [...]
>>> 	This was done historically in bonding, but the call to
>>> bond_update_speed_duplex was removed in commit 876254ae2758 ("bonding:
>>> don't call update_speed_duplex() under spinlocks"), as it might sleep
>>> under lock.  Later, the locking was changed to only hold RTNL, and so
>>> after commit 876254ae2758 ("bonding: don't call update_speed_duplex()
>>> under spinlocks") this call is again safe.
>>> 
>>> Tested-by: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>>> Cc: Veaceslav Falico <vfalico@gmail.com>
>>> Cc: dingtianhong <dingtianhong@huawei.com>
>>> Fixes: 876254ae2758 ("bonding: don't call update_speed_duplex() under spinlocks")
>>> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
>>
>>Applied, thanks Jay.
> 
> 	Rereading the above, I just noticed that I put the wrong commit
> into the fixes tag (and the "Later, the locking was changed" text); the
> correct fixes tag should be:
> 
> Fixes: 4cb4f97b7e36 ("bonding: rebuild the lock use for bond_mii_monitor()")
> 
> 	Kernels between 876254ae2758 and 4cb4f97b7e36 should not have
> this patch applied, as it might sleep under lock.
> 
> 	Sorry for the error,

Ok, thanks for the info.
