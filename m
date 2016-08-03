From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: remove the leftover cleanup_a()
Date: Wed, 3 Aug 2016 08:20:15 -0700
Message-ID: <CAM_iQpVONAiDqgUQhWRbTEUkoEQQPiSUHnpo8aQ8KtGiR1zzFg@mail.gmail.com>
References: <1470159046-23577-1-git-send-email-xiyou.wangcong@gmail.com> <d82351ba-cd1e-d5e1-0faa-94c2bcaf720a@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:35929 "EHLO
	mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbcHCP0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 11:26:31 -0400
Received: by mail-it0-f42.google.com with SMTP id f6so299651059ith.1
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 08:26:30 -0700 (PDT)
In-Reply-To: <d82351ba-cd1e-d5e1-0faa-94c2bcaf720a@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 3, 2016 at 4:36 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> Cong,
>
> Improvement on the basic test as it no longer oopses, but:
> here's a test that will oops:

Make sure you test this together with the other patch I sent
(sorry I didn't number them), the other patch also fixed an oops.


>
> And btw, this should be submitted to -net not -net-next and should
> specify something along the lines of "broken-by .."


Oh, sure, my bad, I thought net-next is still not closed, it should
be already closed. Here it is:

Fixes: a85a970af265 ("net_sched: move tc_action into tcf_common")


Thanks!
