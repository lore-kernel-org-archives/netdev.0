From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next v2] net_sched: use idr to allocate u32 filter
 handles
Date: Tue, 26 Sep 2017 07:36:01 +0200
Message-ID: <20170926053601.GA1948@nanopsycho.orion>
References: <20170925171351.4956-3-xiyou.wangcong@gmail.com>
 <20170925190031.GB1936@nanopsycho.orion>
 <CAM_iQpVDhtznNc8ef1HArX-T0_EDiXyF2p6ze57zvv1AHcrK8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:49909 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965008AbdIZFgD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 01:36:03 -0400
Received: by mail-wm0-f53.google.com with SMTP id r74so3682296wme.4
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 22:36:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpVDhtznNc8ef1HArX-T0_EDiXyF2p6ze57zvv1AHcrK8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 26, 2017 at 01:13:46AM CEST, xiyou.wangcong@gmail.com wrote:
>On Mon, Sep 25, 2017 at 12:00 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Interesting, any idea why this is not 0x7FFFFFFF as well?
>>
>> I wonder if we could have 0x7FFFFFFF magic defined somewhere.
>
>I have no idea, it just exists for a rather long time. Probably too late
>to change, or at least requires a separate patch to change it.

Sure, not saying that you have to do it in this patch. I just wonder if
we could unify this.
