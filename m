From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next v2] net_sched: move the empty tp check from
 ->destroy() to ->delete()
Date: Thu, 13 Apr 2017 09:13:07 -0700
Message-ID: <CAM_iQpUzYT50JpR_ayBFCMZT=80kSM3cnL6dwFcL4XymO=-gNQ@mail.gmail.com>
References: <1492062580-31547-1-git-send-email-xiyou.wangcong@gmail.com> <201704131514.fLLOlm8n%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:33509 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752746AbdDMQN2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 12:13:28 -0400
Received: by mail-wm0-f48.google.com with SMTP id y18so4561350wmh.0
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 09:13:28 -0700 (PDT)
In-Reply-To: <201704131514.fLLOlm8n%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 12:28 AM, kbuild test robot <lkp@intel.com> wrote:
> Hi Cong,
>
> [auto build test WARNING on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Cong-Wang/net_sched-move-the-empty-tp-check-from-destroy-to-delete/20170413-145318
> config: x86_64-randconfig-x004-201715 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All warnings (new ones prefixed by >>):
>
>    net/sched/cls_matchall.c: In function 'mall_destroy':
>>> net/sched/cls_matchall.c:99:10: warning: 'return' with a value, in function returning void
>       return true;
>              ^~~~
>    net/sched/cls_matchall.c:93:13: note: declared here
>     static void mall_destroy(struct tcf_proto *tp)
>                 ^~~~~~~~~~~~
>    net/sched/cls_matchall.c:105:9: warning: 'return' with a value, in function returning void
>      return true;
>             ^~~~
>    net/sched/cls_matchall.c:93:13: note: declared here
>     static void mall_destroy(struct tcf_proto *tp)
>                 ^~~~~~~~~~~~

Ah, I must miss it while compiling... Will send v3 after waiting for
other comments.
