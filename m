From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [Patch net v2] ipv6: ignore null_entry in inet6_rtm_getroute()
 too
Date: Wed, 1 Mar 2017 21:05:04 -0800
Message-ID: <93a4b0f9-8da4-5451-2e7b-9c2cc1ef2921@cumulusnetworks.com>
References: <1488430119-4670-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33263 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750768AbdCBFFe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 00:05:34 -0500
Received: by mail-pg0-f46.google.com with SMTP id 25so28054063pgy.0
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 21:05:07 -0800 (PST)
In-Reply-To: <1488430119-4670-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/1/17 8:48 PM, Cong Wang wrote:
> Like commit 1f17e2f2c8a8 ("net: ipv6: ignore null_entry on route dumps"),
> we need to ignore null entry in inet6_rtm_getroute() too.
> 
> Return -ENETUNREACH here to sync with IPv4 behavior, as suggested by David.
> 
> Fixes: a1a22c1206 ("net: ipv6: Keep nexthop of multipath route on admin down")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv6/route.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 


Acked-by: David Ahern <dsa@cumulusnetworks.com>
