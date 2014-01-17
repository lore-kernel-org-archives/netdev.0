From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v2 2/2] bonding: try to enable SG features when
 adding a new, slave
Date: Fri, 17 Jan 2014 09:59:58 +0800
Message-ID: <52D88E9E.7080705@huawei.com>
References: <52D4FCB3.9000408@huawei.com> <20140116.160721.427996343348396551.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <vfalico@redhat.com>, <edumazet@google.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:35876 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbaAQCBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 21:01:22 -0500
In-Reply-To: <20140116.160721.427996343348396551.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/17 8:07, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Tue, 14 Jan 2014 17:00:35 +0800
> 
>> The commit b0ce3508(bonding: allow TSO being set on bonding master)
>> has make the TSO being set for bond dev, but in some situation, if
>> the slave did not set the NETIF_F_SG features yet, the bond master
>> will miss the TSO features in netdev_fix_features because the TSO is
>> depended on SG.
>>
>> If the slave hw support SG features, but not set yet, I will try to
>> open it when enslave the dev, better for performance.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> 
> I really don't think we should force enable device features in slaves
> that perhaps the user intentionally disabled, or perhaps the driver has
> a reason to disable by default (lower performance, etc.)
> 
> I'm not applying this series, sorry.
> 
> 
Yes, pls miss this one, after the discussion with Veaceslav, I think it is not
reasonable to do this. thanks.

Ding
