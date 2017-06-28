From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Re: [net PATCH] net: sched: Fix one possible panic when no
 destroy callback
Date: Tue, 27 Jun 2017 20:39:40 -0700
Message-ID: <CAM_iQpUG17noUq7n7fGWABi1NvcDRWkjzYT5NWLQC40Ktqg+2A@mail.gmail.com>
References: <1498527333-86838-1-git-send-email-gfree.wind@vip.163.com>
 <CAM_iQpXRy=cC2vuhju2Jf9=sJ+Yc6DvkzvFEU_DrRonyhW+E9w@mail.gmail.com>
 <1498582211.736.118.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUx8d_vQT=1d06Ah-d+E5R_10pnvcy4Y9ac_=txanPBOw@mail.gmail.com>
 <1498585790.736.135.camel@edumazet-glaptop3.roam.corp.google.com> <6da470a2.7d57.15cec319c03.Coremail.gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <gfree.wind@vip.163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33288 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753428AbdF1DkC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 23:40:02 -0400
Received: by mail-wm0-f67.google.com with SMTP id j85so9044534wmj.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 20:40:01 -0700 (PDT)
In-Reply-To: <6da470a2.7d57.15cec319c03.Coremail.gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 27, 2017 at 5:54 PM, Gao Feng <gfree.wind@vip.163.com> wrote:
> At 2017-06-28 01:49:50, "Eric Dumazet" <eric.dumazet@gmail.com> wrote:
>>On Tue, 2017-06-27 at 10:08 -0700, Cong Wang wrote:
>>> On Tue, Jun 27, 2017 at 9:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> > On Tue, 2017-06-27 at 09:30 -0700, Cong Wang wrote:
>>> >> On Mon, Jun 26, 2017 at 6:35 PM,  <gfree.wind@vip.163.com> wrote:
>>> >> > From: Gao Feng <gfree.wind@vip.163.com>
>>> >> >
>>> >> > When qdisc fail to init, qdisc_create would invoke the destroy callback
>>> >> > to cleanup. But there is no check if the callback exists really. So it
>>> >> > would cause the panic if there is no real destroy callback like these
>>> >> > qdisc codel, pfifo, pfifo_fast, and so on.
>>> >> >
>>> >> > Now add one the check for destroy to avoid the possible panic.
>>> >> >
>>> >> > Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
>>> >>
>>> >> Looks good,
>>> >>
>>> >> Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
>>> >>
>>> >> This is introduced by commit 87b60cfacf9f17cf71933c6e33b.
>>> >> Please add proper Fixes tag next time.
>
> OK. Actually I didn't know it is introduced by this commit before :)
> Need I send an update patch again ?
>

Yes please, update the changelog as Eric suggested and also
add Fixes.
