From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Flush per-ns routing cache more sanely.
Date: Tue, 26 Oct 2010 12:20:22 -0700 (PDT)
Message-ID: <20101026.122022.241452738.davem@davemloft.net>
References: <20101026.103428.179941457.davem@davemloft.net>
	<m1sjzs3hbw.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel.lezcano@free.fr
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42292
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755976Ab0JZTT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 15:19:59 -0400
In-Reply-To: <m1sjzs3hbw.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 26 Oct 2010 12:05:39 -0700

>> @@ -999,7 +999,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
>>  		rt_cache_flush(dev_net(dev), 0);
>>  		break;
>>  	case NETDEV_UNREGISTER_BATCH:
>> -		rt_cache_flush_batch();
>> +		rt_cache_flush_batch(dev_net(dev));
> 
> It still has this incorrect conversion in it.

Sorry I missed that, what's the exact problem with it?
