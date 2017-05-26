From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: only create filter chains for new filters/actions
Date: Fri, 26 May 2017 09:55:25 -0700
Message-ID: <CAM_iQpUJcK0ZSqK8=a_D9dBw1OED++A=bC9-UUov4ng0mMpJUg@mail.gmail.com>
References: <1495557757-31371-1-git-send-email-xiyou.wangcong@gmail.com>
 <20170525.121456.221336477222052018.davem@davemloft.net> <20170526055352.GA1898@nanopsycho>
 <20170526.105443.1489276661727770629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiri Pirko <jiri@resnulli.us>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38763 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944373AbdEZQzq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 12:55:46 -0400
Received: by mail-wm0-f44.google.com with SMTP id e127so26110873wmg.1
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 09:55:46 -0700 (PDT)
In-Reply-To: <20170526.105443.1489276661727770629.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 26, 2017 at 7:54 AM, David Miller <davem@davemloft.net> wrote:
> And I also didn't find the boolean logic hard to understand at all.
>
> It is in fact a very common pattern to pass a "create" boolean into
> lookup functions, to tell them whether to create a new object on
> lookup failure or not.  And then also to control that boolean via
> what kind of netlink request we are processing.

+10

It is a widely used pattern among the kernel source code.
I'd be surprised if an experienced kernel developer is not
aware of this pattern. ;)
