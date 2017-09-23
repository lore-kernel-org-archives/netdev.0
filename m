From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2 3/6] rtnetlink: add helper to dump qdisc name
Date: Sat, 23 Sep 2017 11:03:11 -0600
Message-ID: <b17f7e61-08d5-2ab0-229e-10a25e25d000@gmail.com>
References: <20170922061008.14723-1-fw@strlen.de>
 <20170922061008.14723-4-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34587 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdIWRDN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 13:03:13 -0400
Received: by mail-pg0-f67.google.com with SMTP id u18so2460167pgo.1
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2017 10:03:13 -0700 (PDT)
In-Reply-To: <20170922061008.14723-4-fw@strlen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/22/17 12:10 AM, Florian Westphal wrote:
> We can use rcu here to make this safe even if we would not hold rtnl:
> qdisc_destroy uses call_rcu to free the Qdisc struct.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/core/rtnetlink.c | 16 ++++++++++++++--
>  1 file changed, 14 insertions(+), 2 deletions(-)

Reviewed-by: David Ahern <dsahern@gmail.com>
