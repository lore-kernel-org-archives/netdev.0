From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] [PATCH net] net: Do not hold the reference for the same sk_rx_dst.
Date: Thu, 16 Mar 2017 16:13:48 -0700
Message-ID: <CAM_iQpUPYhXkaWK9crnjjHeDoFeH3cofdcjenHvkna90MXvYYQ@mail.gmail.com>
References: <1489651711-4105-1-git-send-email-kaiwen.xu@hulu.com> <1489699996.28631.237.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kevin Xu <kaiwen.xu@hulu.com>, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:36672 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752220AbdCPXOa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 19:14:30 -0400
Received: by mail-wr0-f171.google.com with SMTP id u108so41808524wrb.3
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 16:14:09 -0700 (PDT)
In-Reply-To: <1489699996.28631.237.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 16, 2017 at 2:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Have you backported the redirect fix ?
>
> commit 45caeaa5ac0b4b11784ac6f932c0ad4c6b67cda0
>
> Or other fixes that went very recently (pick David Miller net tree)

Why the commit above is relevant here? It fixes a double-release,
while Kevin's case is a double-hold... Not to mention it sk_rx_dst
instead of sk_dst_cache, according to Kevin.
