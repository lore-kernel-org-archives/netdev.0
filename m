From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net 01/16] net_sched: introduce a workqueue for RCU
 callbacks of tc filter
Date: Fri, 27 Oct 2017 08:52:04 -0700
Message-ID: <1509119524.11887.38.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
         <20171027012443.3306-2-xiyou.wangcong@gmail.com>
         <1509077103.11887.23.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUB_y5=Pa9z5Vq+Ves9GhT5COXvRbDtRZo2xqxjo__vmw@mail.gmail.com>
         <1509079166.11887.33.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXFw8NcVLLgErTNP8yCeZY+wv5zXDfveCcb6cHN0u5NyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:51282 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdJ0PwG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 11:52:06 -0400
Received: by mail-io0-f193.google.com with SMTP id b186so13650770iof.8
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 08:52:06 -0700 (PDT)
In-Reply-To: <CAM_iQpXFw8NcVLLgErTNP8yCeZY+wv5zXDfveCcb6cHN0u5NyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-10-27 at 08:37 -0700, Cong Wang wrote:
> On Thu, Oct 26, 2017 at 9:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2017-10-26 at 21:28 -0700, Cong Wang wrote:
> >> On Thu, Oct 26, 2017 at 9:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> Paul pointed out the same.
> >>
> >> As I replied, this rcu_barrier() is NOT added by this patchset, it is already
> >> there in current master branch.
> >
> > You added the rtnl_lock()  rtnl_unlock()...
> 
> 
> Unfortunately you are wrong again, tcf_block_put() holds RTNL
> in current code as well...

Then current code must be fixed, without adding more crap.

> 

> What stops you to optimize current code?

I might be forced to do so, eventually.
