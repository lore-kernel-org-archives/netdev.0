From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next v2] net_sched: use idr to allocate u32 filter handles
Date: Mon, 25 Sep 2017 16:13:46 -0700
Message-ID: <CAM_iQpVDhtznNc8ef1HArX-T0_EDiXyF2p6ze57zvv1AHcrK8w@mail.gmail.com>
References: <20170925171351.4956-3-xiyou.wangcong@gmail.com> <20170925190031.GB1936@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:53965 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964968AbdIYXOH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 19:14:07 -0400
Received: by mail-pf0-f176.google.com with SMTP id x78so4579836pff.10
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 16:14:07 -0700 (PDT)
In-Reply-To: <20170925190031.GB1936@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 12:00 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Interesting, any idea why this is not 0x7FFFFFFF as well?
>
> I wonder if we could have 0x7FFFFFFF magic defined somewhere.

I have no idea, it just exists for a rather long time. Probably too late
to change, or at least requires a separate patch to change it.
