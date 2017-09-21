From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net_sched: remove cls_flower idr on failure
Date: Thu, 21 Sep 2017 11:50:32 -0700
Message-ID: <CAM_iQpWAWLZ-wg3HBAxp35hZC=ysO65=2qPMCq-sw7PAdSkR3Q@mail.gmail.com>
References: <20170920161845.28753-1-xiyou.wangcong@gmail.com> <CAM_iQpX2QHqPFJ-vZz+6M4oDW2UgTbYdRuCxtNLm14S4sRVONg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Chris Mi <chrism@mellanox.com>, Jiri Pirko <jiri@mellanox.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:54085 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751732AbdIUSux (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 14:50:53 -0400
Received: by mail-pf0-f172.google.com with SMTP id x78so3631595pff.10
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 11:50:53 -0700 (PDT)
In-Reply-To: <CAM_iQpX2QHqPFJ-vZz+6M4oDW2UgTbYdRuCxtNLm14S4sRVONg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 11:47 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, Sep 20, 2017 at 9:18 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> +errout_idr:
>> +       if (fnew->handle)
>> +               idr_remove_ext(&head->handle_idr, fnew->handle);
>
> Hmm, I should check fold instead of fnew->handle here.
> I will update this patch.

Never mind, it should be the same logic. If fold is non-NULL,
then fnew->handle == 0.

It can be applied as it is.
