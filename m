From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 2/2] ipv4: fib: Remove redundant argument
Date: Fri, 10 Mar 2017 09:31:52 -0700
Message-ID: <bc7fb239-48f4-9f3c-9fb0-83276a8c4648@cumulusnetworks.com>
References: <1489132579-12664-1-git-send-email-jiri@resnulli.us>
 <1489132579-12664-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34162 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751316AbdCJQcB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 11:32:01 -0500
Received: by mail-pg0-f48.google.com with SMTP id 77so40519145pgc.1
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 08:31:55 -0800 (PST)
In-Reply-To: <1489132579-12664-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/10/17 12:56 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> We always pass the same event type to fib_notify() and
> fib_rules_notify(), so we can safely drop this argument.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/ip_fib.h    |  9 +++------
>  net/ipv4/fib_notifier.c |  4 ++--
>  net/ipv4/fib_rules.c    |  5 ++---
>  net/ipv4/fib_trie.c     | 15 ++++++---------
>  4 files changed, 13 insertions(+), 20 deletions(-)
> 

Acked-by: David Ahern <dsa@cumulusnetworks.com>
