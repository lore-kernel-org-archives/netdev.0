From: David Miller <davem@davemloft.net>
Subject: Re: [ethtool] ethtool: Remove UDP Fragmentation Offload use from
 ethtool
Date: Mon, 28 Aug 2017 09:38:15 -0700 (PDT)
Message-ID: <20170828.093815.2102161394365439051.davem@davemloft.net>
References: <1503923928-9419-1-git-send-email-tariqt@mellanox.com>
        <1503932411.11498.67.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tariqt@mellanox.com, linville@tuxdriver.com,
        netdev@vger.kernel.org, eranbe@mellanox.com, shakerd@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43300 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdH1QiP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 12:38:15 -0400
In-Reply-To: <1503932411.11498.67.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Aug 2017 08:00:11 -0700

> On Mon, 2017-08-28 at 15:38 +0300, Tariq Toukan wrote:
>> From: Shaker Daibes <shakerd@mellanox.com>
>> 
>> UFO was removed in kernel, here we remove it in ethtool app.
>> 
>> Fixes the following issue:
>> Features for ens8:
>> Cannot get device udp-fragmentation-offload settings: Operation not supported
>> 
>> Tested with "make check"
>> 
>> Signed-off-by: Shaker Daibes <shakerd@mellanox.com>
>> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
>> ---
> 
> 
> Hi guys
> 
> I would rather remove the warning, but leave the ability to switch UFO
> on machines running old kernel but a recent ethtool.
> 
> ethtool does not need to be downgraded every time we boot an old
> kernel ;)

Agreed, we shouldn't be completely removing support for UFO from
ethtool.
