From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/21] mlxsw: Support for IPv6 UC router
Date: Thu, 03 Aug 2017 15:41:24 -0700 (PDT)
Message-ID: <20170803.154124.2094532576602544160.davem@davemloft.net>
References: <20170803112831.1831-1-jiri@resnulli.us>
        <20170803.153631.974713672754752484.davem@davemloft.net>
        <d6bd0d34-b69f-10c2-059d-a45b1dfae80f@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, idosch@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50534 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751866AbdHCWlZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 18:41:25 -0400
In-Reply-To: <d6bd0d34-b69f-10c2-059d-a45b1dfae80f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Thu, 3 Aug 2017 16:39:54 -0600

> On 8/3/17 4:36 PM, David Miller wrote:
>> From: Jiri Pirko <jiri@resnulli.us>
>> Date: Thu,  3 Aug 2017 13:28:10 +0200
>> 
>>> This set adds support for IPv6 unicast routes offload.
>> 
>> Series applied, thanks.
>> 
> 
> I take it you disagree with my comment on patch 10 about the RTF_OFFLOAD
> flag? that is a nexthop flag and has no business being part of the UAPI
> for IPv6.

Oh crap, I missed that.

But unlike the percpu flag, don't we want to somehow propagate offload
state to the user?

I'm sure whatever we decide Jiri will send and appropriate follow-up
so don't panic :)
