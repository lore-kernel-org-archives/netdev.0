From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Thu, 20 Oct 2016 10:17:23 -0700
Message-ID: <CAM_iQpUjbfMdn4wBL=ibQd=mJmKS+Jh-LmsM_LEz8SkOwcPV0A@mail.gmail.com>
References: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com> <eced0989-d8bc-d34e-9ecb-8540d80a7173@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Stephen Smalley <sds@tycho.nsa.gov>, Elad Raz <e@eladraz.com>,
        Paul Moore <paul@paul-moore.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:36515 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932748AbcJTRRr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 13:17:47 -0400
Received: by mail-it0-f47.google.com with SMTP id 139so172356827itm.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 10:17:47 -0700 (PDT)
In-Reply-To: <eced0989-d8bc-d34e-9ecb-8540d80a7173@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2016 at 3:17 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
>
> Now, we see that "it's needed" and that the analysis was wrong. If a race is
> introduced by this patch, it will be hard to detect and fix it.

It is _not_ needed for protection, it is needed to shut up a warning, I thought
this is pretty clear in the changelog.

If we could invent some way to save BH (*lock_bhsave()), we don't need
to bother this at all, currently we don't.
