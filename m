From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 00/21] mlxsw: Support for IPv6 UC router
Date: Thu, 3 Aug 2017 16:39:54 -0600
Message-ID: <d6bd0d34-b69f-10c2-059d-a45b1dfae80f@gmail.com>
References: <20170803112831.1831-1-jiri@resnulli.us>
 <20170803.153631.974713672754752484.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        kafai@fb.com, hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: David Miller <davem@davemloft.net>, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35382 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751944AbdHCWj4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 18:39:56 -0400
Received: by mail-pf0-f170.google.com with SMTP id t86so355961pfe.2
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 15:39:56 -0700 (PDT)
In-Reply-To: <20170803.153631.974713672754752484.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/3/17 4:36 PM, David Miller wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Thu,  3 Aug 2017 13:28:10 +0200
> 
>> This set adds support for IPv6 unicast routes offload.
> 
> Series applied, thanks.
> 

I take it you disagree with my comment on patch 10 about the RTF_OFFLOAD
flag? that is a nexthop flag and has no business being part of the UAPI
for IPv6.
