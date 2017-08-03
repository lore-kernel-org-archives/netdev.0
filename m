From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 00/21] mlxsw: Support for IPv6 UC router
Date: Thu, 3 Aug 2017 16:54:35 -0600
Message-ID: <172d26bc-cb59-c3c7-7ca4-1308f4853e8c@gmail.com>
References: <20170803112831.1831-1-jiri@resnulli.us>
 <20170803.153631.974713672754752484.davem@davemloft.net>
 <d6bd0d34-b69f-10c2-059d-a45b1dfae80f@gmail.com>
 <20170803.154124.2094532576602544160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, idosch@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:38910 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdHCWyh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 18:54:37 -0400
Received: by mail-pg0-f45.google.com with SMTP id l64so359876pge.5
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 15:54:37 -0700 (PDT)
In-Reply-To: <20170803.154124.2094532576602544160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/3/17 4:41 PM, David Miller wrote:
> But unlike the percpu flag, don't we want to somehow propagate offload
> state to the user?

It's a per nexthop flag. For IPv4 it is tracked in fib_nh.nh_flags.
Perhaps it is time for rt6_info to have nh_flags as well.

> 
> I'm sure whatever we decide Jiri will send and appropriate follow-up
> so don't panic :)
> 
