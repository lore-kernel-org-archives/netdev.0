From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] mlx4 misc fixes and improvements
Date: Sun, 18 Sep 2016 22:00:46 -0400 (EDT)
Message-ID: <20160918.220046.1374771296032853447.davem@davemloft.net>
References: <1473686416-11779-1-git-send-email-tariqt@mellanox.com>
        <20160915.192106.739428651744920778.davem@davemloft.net>
        <80a8e8c5-689e-a2b1-e2d4-817dc0649385@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tariqt@mellanox.com, netdev@vger.kernel.org, eranbe@mellanox.com
To: ttoukan.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51496 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936368AbcISCAx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 22:00:53 -0400
In-Reply-To: <80a8e8c5-689e-a2b1-e2d4-817dc0649385@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <ttoukan.linux@gmail.com>
Date: Sun, 18 Sep 2016 10:27:23 +0300

> Hi Dave,
> 
> On 16/09/2016 2:21 AM, David Miller wrote:
>> From: Tariq Toukan <tariqt@mellanox.com>
>> Date: Mon, 12 Sep 2016 16:20:11 +0300
>>
>>> This patchset contains some bug fixes, a cleanup, and small
>>> improvements
>>> from the team to the mlx4 Eth and core drivers.
>>>
>>> Series generated against net-next commit:
>>> 02154927c115 "net: dsa: bcm_sf2: Get VLAN_PORT_MASK from b53_device"
>>>
>>> Please push the following patch to -stable  >= 4.6 as well:
>>> "net/mlx4_core: Fix to clean devlink resources"
>> Again, coding style fixes and optimizations like branch prediction
>> hints are not bug fixes and therefore not appropriate for 'net'.
> Yes, I know. Please notice that it was submitted to net-next this
> time.

This is completely incompatible with a request for one of the changes
to go into -stable.

If the change is not in 'net', it can't go to -stable.
