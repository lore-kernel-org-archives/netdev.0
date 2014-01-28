From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next v2 1/5] net_sched: act: hide struct tcf_common
 from API
Date: Mon, 27 Jan 2014 21:17:12 -0800
Message-ID: <CAM_iQpV_8=f=EZfbYOzTb40NA881x-ii3nPqLK2EQGOa4nxang@mail.gmail.com>
References: <1390516525-8556-1-git-send-email-xiyou.wangcong@gmail.com>
	<1390516525-8556-2-git-send-email-xiyou.wangcong@gmail.com>
	<52E64D03.7000506@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:33436 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbaA1FRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 00:17:12 -0500
Received: by mail-ob0-f179.google.com with SMTP id wo20so7527014obc.38
        for <netdev@vger.kernel.org>; Mon, 27 Jan 2014 21:17:12 -0800 (PST)
In-Reply-To: <52E64D03.7000506@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 27, 2014 at 4:11 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 01/23/14 17:35, Cong Wang wrote:
>>
>> Now we can totally hide it from modules. tcf_hash_*() API's
>> will operate on struct tc_action, modules don't need to care about
>> the details.
>>
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>
>
> Cong, this patch does not compile by itself. I did not try the rest.
> For git bisect to work:
> Every patch should be compilable standalone and all tests should
> pass with every single patch (the later part is my view, the first
> is common practise)

I knew, and I thought I did compile-test for every patch, seems
I missed something during update, or you use a different config
to trigger the compile error.

>
> Since Dave already closed the door - no rush, when you get the
> cycles please fix this up. I am hoping to do a quick test run
> when you are done.
>

Yeah, I asked Dave in another thread and decided to wait
for the next net-next.

Thanks.
