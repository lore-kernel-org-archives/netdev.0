From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1][net-next] dccp: catch failed request_module call
 in dccp_probe init
Date: Thu, 19 Dec 2013 19:26:22 -0500 (EST)
Message-ID: <20131219.192622.834123418473103745.davem@davemloft.net>
References: <52B043D9.9090808@huawei.com>
	<20131217192433.168b39ef@liptov.cs.ualberta.ca>
	<52B10AAC.3070400@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602Ab3LTA0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 19:26:24 -0500
In-Reply-To: <52B10AAC.3070400@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Wed, 18 Dec 2013 10:38:36 +0800

> On 2013/12/18 10:24, Gerrit Renker wrote:
>> Hi Wang,
>> 
>> thank you for the patch, please find refactored version below, changes are
>>  (a) if request_module fails, return its error code instead of the previous ret,
>>  (b) refactor code -- setup_jprobe becomes superfluous.
>> 
>> Please add your signed off if ok, since it is essentially your patch.
>> 
>>>>>>>>>>>>>>>>>>>>>>>>> Wang's patch revised <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>> dccp: catch failed request_module call in dccp_probe init
>> 
>> Check the return value of request_module during dccp_probe initialisation,
>> bail out if that call fails.
>> 
>> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
 ...
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thanks.
