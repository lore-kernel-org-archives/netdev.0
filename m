From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bonding: fix error return code in bond_enslave()
Date: Sun, 25 Aug 2013 18:38:48 -0400 (EDT)
Message-ID: <20130825.183848.1884215579679368408.davem@davemloft.net>
References: <CAPgLHd96k-qncCXzzVogwtmMdaYUDsMShdX52YSLAdbTiN1uEw@mail.gmail.com>
	<52176720.60300@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, fubar@us.ibm.com, andy@greyhouse.net,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756416Ab3HYWiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 18:38:50 -0400
In-Reply-To: <52176720.60300@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Fri, 23 Aug 2013 15:44:00 +0200

> On 08/23/2013 04:45 AM, Wei Yongjun wrote:
>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>> 
>> Fix to return a negative error code in the add bond vlan ids error
>> handling case instead of 0, as done elsewhere in this function.
>> 
>> Introduced by commit 1ff412ad7714f6952f76ffd77f0a7f2f563288a1.
>> (bonding: change the bond's vlan syncing functions with the standard ones)
>> 
>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Oops, missed the error code. Thanks :-)
> 
> Acked-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied.
