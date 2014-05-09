From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv4: move local_port_range out of
 CONFIG_SYSCTL
Date: Thu, 08 May 2014 22:52:21 -0400 (EDT)
Message-ID: <20140508.225221.188940173991264163.davem@davemloft.net>
References: <1399399370-7849-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140507.172641.1968628089443229607.davem@davemloft.net>
	<20140507224848.GA1272@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754574AbaEICwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 22:52:23 -0400
In-Reply-To: <20140507224848.GA1272@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 8 May 2014 00:48:48 +0200

> David Miller <davem@davemloft.net> :
> [...]
>> I think these two changes fix fairly serious issues that have existed for some
>> time, so it should go into 'net', do you agree?
> 
> Patch #1, yes.
> 
> Without patch #2, the root group id is always granted ping init when
> CONFIG_SYSCTL is not set. It's more cautious than serious.

Still, initializing such fundamental values to different defaults
based upon whether SYSCTL is enabled or not is pretty bad, so I've
decided to apply both patches to 'net'.

Thanks.
