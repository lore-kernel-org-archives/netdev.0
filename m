From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net v2 1/2] bonding: Fix RTNL: assertion failed at net/core/rtnetlink.c
 for 802.3ad mode
Date: Wed, 26 Feb 2014 09:47:36 +0800
Message-ID: <530D47B8.1010609@huawei.com>
References: <1392800711-19264-1-git-send-email-dingtianhong@huawei.com>	<1392800711-19264-2-git-send-email-dingtianhong@huawei.com> <20140225.173244.1761467022630063500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<cwang@twopensource.com>, <jiri@resnulli.us>,
	<thomas@glanzmann.de>, <eric.dumazet@gmail.com>,
	<sfeldma@cumulusnetworks.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:6269 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbaBZBsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 20:48:02 -0500
In-Reply-To: <20140225.173244.1761467022630063500.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/26 6:32, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Wed, 19 Feb 2014 17:05:10 +0800
> 
>> @@ -2062,6 +2062,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>>  	struct list_head *iter;
>>  	struct slave *slave;
>>  	struct port *port;
>> +	int slave_should_notify = 0;
> 
> Please use bool, true/false, for slave_should_notify.
> 
> Thanks.
> 
> .
> 

Yes, thanks, also fix the 2 patch.

Ding 
