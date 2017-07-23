From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Sat, 22 Jul 2017 21:55:51 -0700
Message-ID: <CAJieiUiZRkd81BVAkDdENu9T0uBZ31OQDUAFZ+jzNnBJaHx-+g@mail.gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        WANG Cong <xiyou.wangcong@gmail.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f174.google.com ([209.85.217.174]:38827 "EHLO
        mail-ua0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750758AbdGWEzw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2017 00:55:52 -0400
Received: by mail-ua0-f174.google.com with SMTP id w45so61413858uac.5
        for <netdev@vger.kernel.org>; Sat, 22 Jul 2017 21:55:52 -0700 (PDT)
In-Reply-To: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 20, 2017 at 7:51 AM, Hangbin Liu <liuhangbin@gmail.com> wrote:
> After commit 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib
> result when requested"). When we get a prohibit ertry, we will return
> -EACCES directly.
>
> Before:
> + ip netns exec client ip -6 route get 2003::1
> prohibit 2003::1 dev lo table unspec proto kernel src 2001::1 metric
> 4294967295 error -13
>
> After:
> + ip netns exec server ip -6 route get 2002::1
> RTNETLINK answers: Network is unreachable
>
> Since we will check the ip6_null_entry later. There is not sense
> to check the dst.error after get rt.
>
> Fixes: 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib...")
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>


thanks.
