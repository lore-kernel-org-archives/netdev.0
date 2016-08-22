From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: properly handle failure case of
 tcf_exts_init()
Date: Mon, 22 Aug 2016 08:11:03 -0400
Message-ID: <09b957e2-5a37-643d-9cc1-2bbddc4ad8b4@mojatatu.com>
References: <1471635414-32433-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33054 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751437AbcHVMLv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 08:11:51 -0400
Received: by mail-it0-f67.google.com with SMTP id d65so4672774ith.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 05:11:14 -0700 (PDT)
In-Reply-To: <1471635414-32433-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-19 03:36 PM, Cong Wang wrote:
> After commit 22dc13c837c3 ("net_sched: convert tcf_exts from list to pointer array")
> we do dynamic allocation in tcf_exts_init(), therefore we need
> to handle the ENOMEM case properly.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Answered my own question by looking at implementation of kfree();
ignores NULL (unlike free())

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
