From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/8] net/mlx4: Address build warnings on set
 but not used variables
Date: Tue, 15 May 2012 01:59:16 -0400 (EDT)
Message-ID: <20120515.015916.1228365475475285173.davem@davemloft.net>
References: <1337025853-26685-2-git-send-email-ogerlitz@mellanox.com>
	<20120515.000754.1011080018257342361.davem@davemloft.net>
	<4FB1EF06.6070909@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35137 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab2EOF7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 01:59:25 -0400
In-Reply-To: <4FB1EF06.6070909@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 15 May 2012 08:52:06 +0300

> On 5/15/2012 7:07 AM, David Miller wrote:
>>
>>> -		err = mlx4_qp_detach_common(dev,&qp, rgid->gid, rgid->prot,
>>> + (void) mlx4_qp_detach_common(dev,&qp, rgid->gid, rgid->prot,
>>>   					    rgid->steer);
>>
>> You must update the indentation of all the lines comprising of the
>> function call when you change the indentation of it's initial line.
> 
> Just want to make sure I understood right what has to be done here,
> e.g in this case its needs to be
> like this?
 ...
>> -                                           rgid->steer);
>> + (void) mlx4_qp_detach_common(dev, &qp, rgid->gid, rgid->prot,
>> +                                                   rgid->steer);

I can't tell if it's right, becuase it got all reformatted by your
mail client.

You simply need to make sure the arguments on the second and
further lines line up with the column after the openning
parenthesis on the first line.
