From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v4 net-next] rtnetlink: bridge: use ext_ack instead of
 printk
Date: Tue, 10 Oct 2017 09:11:15 -0600
Message-ID: <c152d9f3-deb5-a1c7-d1c4-caa8a80bd985@gmail.com>
References: <20171010151004.20056-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:37117 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756058AbdJJPLQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 11:11:16 -0400
Received: by mail-pf0-f196.google.com with SMTP id z80so17794630pff.4
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 08:11:16 -0700 (PDT)
In-Reply-To: <20171010151004.20056-1-fw@strlen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/17 9:10 AM, Florian Westphal wrote:
> We can now piggyback error strings to userspace via extended acks
> rather than using printk.
> 
> Before:
> bridge fdb add 01:02:03:04:05:06 dev br0 vlan 4095
> RTNETLINK answers: Invalid argument
> 
> After:
> bridge fdb add 01:02:03:04:05:06 dev br0 vlan 4095
> Error: invalid vlan id.
> 
> v3: drop 'RTM_' prefixes, suggested by David Ahern, they
> are not useful, the add/del in bridge command line is enough.
> 
> Also reword error in response to malformed/bad vlan id attribute
> size.
> 
> Cc: David Ahern <dsahern@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  change since v3: forgot to remove "RTM_SETLINK:" prefix in error message.
> 
>  net/core/rtnetlink.c | 28 ++++++++++++++--------------
>  1 file changed, 14 insertions(+), 14 deletions(-)

Reviewed-by: David Ahern <dsahern@gmail.com>
