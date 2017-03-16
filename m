From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] [PATCH net] net: Do not hold the reference for the same
 sk_rx_dst.
Date: Thu, 16 Mar 2017 16:29:05 -0700
Message-ID: <1489706945.28631.270.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489651711-4105-1-git-send-email-kaiwen.xu@hulu.com>
         <1489699996.28631.237.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUPYhXkaWK9crnjjHeDoFeH3cofdcjenHvkna90MXvYYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kevin Xu <kaiwen.xu@hulu.com>, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33828 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752072AbdCPX3I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 19:29:08 -0400
Received: by mail-pf0-f194.google.com with SMTP id o126so7222218pfb.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 16:29:07 -0700 (PDT)
In-Reply-To: <CAM_iQpUPYhXkaWK9crnjjHeDoFeH3cofdcjenHvkna90MXvYYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-16 at 16:13 -0700, Cong Wang wrote:
> On Thu, Mar 16, 2017 at 2:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Have you backported the redirect fix ?
> >
> > commit 45caeaa5ac0b4b11784ac6f932c0ad4c6b67cda0
> >
> > Or other fixes that went very recently (pick David Miller net tree)
> 
> Why the commit above is relevant here? It fixes a double-release,
> while Kevin's case is a double-hold... Not to mention it sk_rx_dst
> instead of sk_dst_cache, according to Kevin.

Yes you are right.

I was lazy, the other fix I wanted to mention was 
02b2faaf0af1d85585f

In any case I wanted to make sure the reported issue is not for some old
kernels.
