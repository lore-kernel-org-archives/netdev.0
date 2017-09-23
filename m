From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2 2/6] rtnetlink: add helper to put master
 ifindex
Date: Sat, 23 Sep 2017 11:01:25 -0600
Message-ID: <83d6bda6-ec28-31bb-5594-4d7e95a3cd72@gmail.com>
References: <20170922061008.14723-1-fw@strlen.de>
 <20170922061008.14723-3-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37513 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdIWRB1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 13:01:27 -0400
Received: by mail-pg0-f68.google.com with SMTP id v5so2444096pgn.4
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2017 10:01:27 -0700 (PDT)
In-Reply-To: <20170922061008.14723-3-fw@strlen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/22/17 12:10 AM, Florian Westphal wrote:
> rtnl_fill_ifinfo currently requires caller to hold the rtnl mutex.
> Unfortunately the function is quite large which makes it harder to see
> which spots need the lock, which spots assume it and which ones could do
> without.
> 
> Add helpers to factor out the ifindex dumping.
> 
> One helper can use rcu to remove rtnl dependency.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/core/rtnetlink.c | 32 +++++++++++++++++++++++++++-----
>  1 file changed, 27 insertions(+), 5 deletions(-)

Reviewed-by: David Ahern <dsahern@gmail.com>
