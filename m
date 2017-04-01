From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] net: Remove unnecessary cast on void pointer
Date: Sat, 1 Apr 2017 16:48:21 -0700
Message-ID: <20170401164821.036f1b41@plumbers-lap.home.lan>
References: <20170328190516.GA19531@singhal-Inspiron-5558>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com, gregkh@linuxfoundation.org,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        bridge@lists.linux-foundation.org
To: simran singhal <singhalsimran0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:36673 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751942AbdDAXs0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 19:48:26 -0400
Received: by mail-pg0-f47.google.com with SMTP id g2so92620373pge.3
        for <netdev@vger.kernel.org>; Sat, 01 Apr 2017 16:48:26 -0700 (PDT)
In-Reply-To: <20170328190516.GA19531@singhal-Inspiron-5558>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Mar 2017 00:35:16 +0530
simran singhal <singhalsimran0@gmail.com> wrote:

> The following Coccinelle script was used to detect this:
> @r@
> expression x;
> void* e;
> type T;
> identifier f;
> @@
> (
>   *((T *)e)
> |
>   ((T *)x)[...]
> |
>   ((T*)x)->f
> |
> 
> - (T*)
>   e
> )
> 
> Unnecessary parantheses are also remove.
> 
> Signed-off-by: simran singhal <singhalsimran0@gmail.com>

Looks good

Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
