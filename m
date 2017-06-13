From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net_sched: move tcf_lock down after gen_replace_estimator()
Date: Tue, 13 Jun 2017 13:45:20 -0700
Message-ID: <CAM_iQpV_B5oZRtU5mj90PAXnhk+JCJsQ0B=Or3eyx6VBMzuOLQ@mail.gmail.com>
References: <1497386184-14960-1-git-send-email-xiyou.wangcong@gmail.com> <20170613204040.GB3112@yuvallap>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        nicholashuber@gmail.com, Laura Abbott <labbott@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33341 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751793AbdFMUpm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 16:45:42 -0400
Received: by mail-wr0-f194.google.com with SMTP id v104so33621317wrb.0
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 13:45:41 -0700 (PDT)
In-Reply-To: <20170613204040.GB3112@yuvallap>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 13, 2017 at 1:40 PM, Yuval Shaia <yuval.shaia@oracle.com> wrote:
> On Tue, Jun 13, 2017 at 01:36:24PM -0700, Cong Wang wrote:
>> Laura reported a sleep-in-atomic kernel warning inside
>
> Since you added a Reported-by tag below i don't see a reason to
> specifically mention it in commit log message.

If you have faith in this, feel free to update netdev-FAQ.txt to save
your time and others' time in the future.

Thanks.
