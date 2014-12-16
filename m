From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4: Cache line CQE/EQE stride fixes
Date: Tue, 16 Dec 2014 15:24:25 -0500 (EST)
Message-ID: <20141216.152425.1016281144823050984.davem@davemloft.net>
References: <1418729334-2974-1-git-send-email-amirv@mellanox.com>
	<54902597.50105@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, clsoto@linux.vnet.ibm.com,
	idos@mellanox.com, weiyang@linux.vnet.ibm.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbaLPUY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 15:24:28 -0500
In-Reply-To: <54902597.50105@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 16 Dec 2014 14:29:11 +0200

> On 12/16/2014 1:28 PM, Amir Vadai wrote:
>> From: Ido Shamay <idos@mellanox.com>
>> 
>> This commit contains 2 fixes for the 128B CQE/EQE stride feaure.
>> Wei found that mlx4_QUERY_HCA function marked the wrong capability
>> in flags (64B CQE/EQE), when CQE/EQE stride feature was enabled.
>> Also added small fix in initial CQE ownership bit assignment, when CQE
>> is size is not default 32B.
>> 
>> Fixes: 77507aa24 (net/mlx4: Enable CQE/EQE stride support)
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> Signed-off-by: Ido Shamay <idos@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>> Dave Hi,
>> 
>> Please pull this patch also to stable (at least 3.17)
>> 
>> Thanks,
>> Amir
> 
> Small correction: Should pull into -stable >= 3.18

Applied and queued up for -stable, thanks.
