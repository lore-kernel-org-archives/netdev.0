From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 1/6] ipv4: fib: Set offload indication according
 to nexthop flags
Date: Wed, 2 Aug 2017 17:01:30 -0600
Message-ID: <9232015f-01fc-6131-b64d-3abc68d8f7e5@gmail.com>
References: <20170802075606.1090-1-jiri@resnulli.us>
 <20170802075606.1090-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33162 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdHBXBd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 19:01:33 -0400
Received: by mail-pf0-f180.google.com with SMTP id d67so26653332pfc.0
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 16:01:33 -0700 (PDT)
In-Reply-To: <20170802075606.1090-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/17 1:56 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> We're going to have capable drivers indicate route offload using the
> nexthop flags, but for non-multipath routes these flags aren't dumped to
> user space.
> 
> Instead, set the offload indication in the route message flags.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  net/ipv4/fib_semantics.c | 2 ++
>  1 file changed, 2 insertions(+)

Acked-by: David Ahern <dsahern@gmail.com>
