From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: use idr to allocate bpf filter handles
Date: Mon, 25 Sep 2017 09:49:46 -0700
Message-ID: <CAM_iQpX3rFubq2zj0Hz=MhqtTbMr1qWnwxghYG6_0dcTVKPH-w@mail.gmail.com>
References: <20170921234302.26558-1-xiyou.wangcong@gmail.com>
 <20170923.171534.1037317649165173409.davem@davemloft.net> <CAM_iQpVOnzqAs6sT8=n+n2zFUNd_K4evph3=68NL1CtBN=AAmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Chris Mi <chrism@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:48319 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752558AbdIYQuG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 12:50:06 -0400
Received: by mail-pf0-f180.google.com with SMTP id n24so4075275pfk.5
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 09:50:06 -0700 (PDT)
In-Reply-To: <CAM_iQpVOnzqAs6sT8=n+n2zFUNd_K4evph3=68NL1CtBN=AAmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 9:46 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sat, Sep 23, 2017 at 5:15 PM, David Miller <davem@davemloft.net> wrote:
>> If I read the code properly, the existing code allows IDs from '1' to
>> and including '0x7ffffffe', whereas the new code allows up to and
>> including '0x7ffffffff'.
>>
>> Whether intentional or not this is a change in behavior.  If it's OK,
>> it should be at least documented either in a comment or in the
>> commit log itself.
>>
>> Similarly for your other scheduler IDR changes.
>
> Good catch! Obviously off-by-one. I agree we should keep
> the old behavior no matter the reason.
>
> I will update the patches.
>

By the way, same problem for commit fe2502e49b58606580c77.
:)
