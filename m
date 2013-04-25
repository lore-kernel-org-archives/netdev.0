From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] irda: irlmp_reasons[] can be static
Date: Thu, 25 Apr 2013 01:43:04 -0400 (EDT)
Message-ID: <20130425.014304.898755344366767132.davem@davemloft.net>
References: <5171ea81.dFNn973/RcdmuuQR%fengguang.wu@intel.com>
	<20130420031045.GC7366@localhost>
	<20130420111151.GE26896@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab3DYFnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:43:07 -0400
In-Reply-To: <20130420111151.GE26896@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 20 Apr 2013 14:11:51 +0300

> On Sat, Apr 20, 2013 at 11:10:45AM +0800, Fengguang Wu wrote:
>> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
>> ---
>>  irlmp.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
>> index 1064621..98ad6ec 100644
>> --- a/net/irda/irlmp.c
>> +++ b/net/irda/irlmp.c
>> @@ -58,7 +58,7 @@ int  sysctl_discovery_slots   = 6; /* 6 slots by default */
>>  int  sysctl_lap_keepalive_time = LM_IDLE_TIMEOUT * 1000 / HZ;
>>  char sysctl_devname[65];
>>  
>> -const char *irlmp_reasons[] = {
>> +static const char *irlmp_reasons[] = {
> 
> Oops.  Sorry for that.  I do run Sparse on my patches but I missed
> that.
> 
> Acked-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to net-next, thanks everyone.
