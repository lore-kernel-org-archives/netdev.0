From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next] net_sched: only create filter chains for new
 filters/actions
Date: Sat, 27 May 2017 12:05:59 +0200
Message-ID: <20170527100559.GC1831@nanopsycho>
References: <1495557757-31371-1-git-send-email-xiyou.wangcong@gmail.com>
 <20170525.121456.221336477222052018.davem@davemloft.net>
 <20170526055352.GA1898@nanopsycho>
 <20170526.105443.1489276661727770629.davem@davemloft.net>
 <CAM_iQpUJcK0ZSqK8=a_D9dBw1OED++A=bC9-UUov4ng0mMpJUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34809 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755407AbdE0KGD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 06:06:03 -0400
Received: by mail-wm0-f68.google.com with SMTP id d127so7645550wmf.1
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 03:06:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpUJcK0ZSqK8=a_D9dBw1OED++A=bC9-UUov4ng0mMpJUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 26, 2017 at 06:55:25PM CEST, xiyou.wangcong@gmail.com wrote:
>On Fri, May 26, 2017 at 7:54 AM, David Miller <davem@davemloft.net> wrote:
>> And I also didn't find the boolean logic hard to understand at all.
>>
>> It is in fact a very common pattern to pass a "create" boolean into
>> lookup functions, to tell them whether to create a new object on
>> lookup failure or not.  And then also to control that boolean via
>> what kind of netlink request we are processing.
>
>+10
>
>It is a widely used pattern among the kernel source code.
>I'd be surprised if an experienced kernel developer is not
>aware of this pattern. ;)

Cong, as you wisely put, I'm not aware of this pattern and I'm also
unaware of existence of ternary operator. Are this notes necessary?
Does that make you feel better?
