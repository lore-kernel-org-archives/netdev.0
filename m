From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net 0/2] bonding: ensure that the TSO being set on bond
 master
Date: Tue, 14 Jan 2014 10:06:28 +0800
Message-ID: <52D49BA4.7040706@huawei.com>
References: <52CCFE15.2020605@huawei.com> <20140113.111511.1204304092822372663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <vfalico@redhat.com>, <edumazet@google.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:12066 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbaANCGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 21:06:51 -0500
In-Reply-To: <20140113.111511.1204304092822372663.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/14 3:15, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Wed, 8 Jan 2014 15:28:21 +0800
> 
>> The commit b0ce3508(bonding: allow TSO being set on bonding master)
>> has make the TSO being set for bond dev, but in some situation, if
>> the slave did not have the NETIF_F_SG features, the bond master will
>> miss the TSO features in netdev_fix_features because the TSO is
>> depended on SG. So I have to add SG and TSO features on bond master
>> together.
>>
>> The function netdev_add_tso_features() was only be used for bonding,
>> so no need to export it in netdevice.h, remove it and add it to bonding.
> 
> As far as I can tell from the discussion, there is some issue wrt. TSO
> about what happens if SG is not supported by some of the slaves.
> 
>>From my perspective it appears that some changes to these patches are
> necessary to handle that correctly.
> 
> So I am going to mark them as "Changes Requested" in patchwork.
> 
> If this is not the case, please resubmit these changes with appropriate
> explanations added to the commit message(s).
> 
> Thanks.
> 
> 

Ok, thanks.

Regards
Ding
