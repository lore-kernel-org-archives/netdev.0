From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 2/9] ipv4: fib_rules: Add notifier info to FIB
 rules notifications
Date: Wed, 15 Mar 2017 09:16:47 -0600
Message-ID: <8f79898c-3708-5001-54f9-e882c05075a8@cumulusnetworks.com>
References: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
 <1489575912-6469-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        shm@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, lorenzo@google.com,
        mateusz.bajorski@nokia.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34036 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdCOPQv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 11:16:51 -0400
Received: by mail-pf0-f180.google.com with SMTP id v190so10258378pfb.1
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 08:16:50 -0700 (PDT)
In-Reply-To: <1489575912-6469-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/17 5:05 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Whenever a FIB rule is added or removed, a notification is sent in the
> FIB notification chain. However, listeners don't have a way to tell
> which rule was added or removed.
> 
> This is problematic as we would like to give listeners the ability to
> decide which action to execute based on the notified rule. Specifically,
> offloading drivers should be able to determine if they support the
> reflection of the notified FIB rule and flush their LPM tables in case
> they don't.
> 
> Do that by adding a notifier info to these notifications and embed the
> common FIB rule struct in it.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/ip_fib.h |  5 +++++
>  net/ipv4/fib_rules.c | 13 ++++++++-----
>  2 files changed, 13 insertions(+), 5 deletions(-)

Acked-by: David Ahern <dsa@cumulusnetworks.com>
