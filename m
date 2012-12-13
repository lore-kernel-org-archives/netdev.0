From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: do not check x->km.state
Date: Thu, 13 Dec 2012 14:19:22 -0500 (EST)
Message-ID: <20121213.141922.2249665409902614569.davem@davemloft.net>
References: <1355389560-7705-1-git-send-email-roy.qing.li@gmail.com>
	<20121213101948.GG18940@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755976Ab2LMTTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 14:19:24 -0500
In-Reply-To: <20121213101948.GG18940@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 13 Dec 2012 11:19:48 +0100

> On Thu, Dec 13, 2012 at 05:06:00PM +0800, roy.qing.li@gmail.com wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>> 
>> do not check x->km.state, it will be checked by succedent
>> xfrm_state_check_expire()
>> 
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
 ...
> This would remove the only place where the LINUX_MIB_XFRMINSTATEINVALID
> statistics counter is incremented. I think it would be better to ensure
> a valid state before we call xfrm_state_check_expire(). This would make
> the statistics more accurate and we can remove the x->km.state check
> from xfrm_state_check_expire().

Agreed.
