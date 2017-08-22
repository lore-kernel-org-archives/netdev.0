From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Re: [PATCH net-next] net: sched: Add the invalid handle check in qdisc_class_find
Date: Mon, 21 Aug 2017 17:51:22 -0700
Message-ID: <CAM_iQpXoE==0Y+WBsz75YEESg9M-5gQEjomC9VCbtcnwSGzqyQ@mail.gmail.com>
References: <1503041004-105572-1-git-send-email-gfree.wind@vip.163.com>
 <20170821.104749.419102990180912192.davem@davemloft.net> <CAM_iQpW_odL=iqONVX2cLqPr_XQ-J40Ruv+kYMvwPThR42Udrg@mail.gmail.com>
 <caf756f.76ba.15e0767aea0.Coremail.gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Gao Feng <gfree.wind@vip.163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37349 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754049AbdHVAvn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 20:51:43 -0400
Received: by mail-pg0-f65.google.com with SMTP id 83so26010986pgb.4
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 17:51:43 -0700 (PDT)
In-Reply-To: <caf756f.76ba.15e0767aea0.Coremail.gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 5:46 PM, Gao Feng <gfree.wind@vip.163.com> wrote:
> Hi Cong,
>
> Thanks your reminder firstly.
> But I had used the get_maintainer.pl actually before sent the patch.
>
> The following is the output.
> [fgao@ikuai8 net-next]#./scripts/get_maintainer.pl patch_ScheCheck/0001-net-sched-Add-the-invalid-handle-check-in-qdisc_clas.patch
> "David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING [GENERAL])
> netdev@vger.kernel.org (open list:NETWORKING [GENERAL])
> linux-kernel@vger.kernel.org (open list)
>
> I don't know if it is an issue of the script "get_maintainer.pl"  or my usage is wrong.

No, probably because we don't add include/net/sch_generic.h into TC
subsystem, while we should.
