From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 10/17] ipv6: fib: Add offload indication to
 routes
Date: Wed, 19 Jul 2017 09:27:30 -0600
Message-ID: <21bdef55-9cd2-8a17-9eaa-a10cfc6ef4d4@gmail.com>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-11-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        kafai@fb.com, hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33203 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755249AbdGSP1d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 11:27:33 -0400
Received: by mail-pf0-f193.google.com with SMTP id e199so281876pfh.0
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 08:27:33 -0700 (PDT)
In-Reply-To: <20170719070232.28457-11-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/19/17 1:02 AM, Jiri Pirko wrote:
> Allow user space applications to see which routes are offloaded and
> which aren't by setting the RTNH_F_OFFLOAD flag when dumping them.
> 
> To be consistent with IPv4, a multipath route is marked as offloaded if
> one of its nexthops is offloaded. Individual nexthops aren't marked with
> the 'offload' flag.

It is more user friendly to report the offload per nexthop especially
given the implications. There are already flags per nexthop and those
flags are pushed to userspace so not an API change at all.
