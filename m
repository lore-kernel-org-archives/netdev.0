From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 1/2] ipv4: fib: Move FIB notification code to a
 separate file
Date: Fri, 10 Mar 2017 09:31:45 -0700
Message-ID: <8b973337-ee87-c833-b223-b9ffbc562cc0@cumulusnetworks.com>
References: <1489132579-12664-1-git-send-email-jiri@resnulli.us>
 <1489132579-12664-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:32900 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751316AbdCJQbt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 11:31:49 -0500
Received: by mail-pg0-f51.google.com with SMTP id 25so40647880pgy.0
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 08:31:48 -0800 (PST)
In-Reply-To: <1489132579-12664-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/10/17 12:56 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Most of the code concerned with the FIB notification chain currently
> resides in fib_trie.c, but this isn't really appropriate, as the FIB
> notification chain is also used for FIB rules.
> 
> Therefore, it makes sense to move the common FIB notification code to a
> separate file and have it export the relevant functions, which can be
> invoked by its different users (e.g., fib_trie.c, fib_rules.c).
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/ip_fib.h    | 15 ++++++++
>  net/ipv4/Makefile       |  2 +-
>  net/ipv4/fib_notifier.c | 86 +++++++++++++++++++++++++++++++++++++++++++
>  net/ipv4/fib_rules.c    |  9 +++++
>  net/ipv4/fib_trie.c     | 97 +------------------------------------------------
>  5 files changed, 113 insertions(+), 96 deletions(-)
>  create mode 100644 net/ipv4/fib_notifier.c
> 

Acked-by: David Ahern <dsa@cumulusnetworks.com>
