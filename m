From: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Subject: RE: [PATCH] ixgbe: missing parentheses
Date: Thu, 16 Apr 2009 14:25:44 -0700
Message-ID: <A78C6259B11833419567082E2DC0C256CB288425@orsmsx508.amr.corp.intel.com>
References: <49E79D7C.2080200@gmail.com>
 <20090416141610.ad8b9909.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50496 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751228AbZDPVZr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 17:25:47 -0400
In-Reply-To: <20090416141610.ad8b9909.akpm@linux-foundation.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>On Thursday, April 16, 2009 Andrew Morton wrote:
>
>(cc netdev)
>
>On Thu, 16 Apr 2009 23:05:00 +0200
>Roel Kluin <roel.kluin@gmail.com> wrote:
>
>> `!' has a higher precedence than `&'
>>
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>> ---
>> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
>> index febde45..49a9037 100644
>> --- a/drivers/net/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ixgbe/ixgbe_main.c
>> @@ -3946,7 +3946,7 @@ static void ixgbe_sfp_config_module_task(struct
>work_struct *work)
>>  	}
>>  	hw->mac.ops.setup_sfp(hw);
>>
>> -	if (!adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK)
>> +	if (!(adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK))
>>  		/* This will also work for DA Twinax connections */
>>  		schedule_work(&adapter->multispeed_fiber_task);
>>  	adapter->flags &= ~IXGBE_FLAG_IN_SFP_MOD_TASK;
>
>This is fixed in linux-next, but hasn't been pushed to Linus yet.

Yes, Dave has this fix in his net-next-2.6 tree.

Dave - Can we pull this fix into net-2.6?

Cheers,
Jeff

