From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 0/1] Introduction of the tc tests
Date: Mon, 19 Jun 2017 21:13:31 -0700
Message-ID: <CAM_iQpX-9No6RT1KEUJkd_smKjtxUJ1ZiYBwXOHJzR=1t_wBSA@mail.gmail.com>
References: <1497648155-25521-1-git-send-email-lucasb@mojatatu.com>
 <CAM_iQpUxfGrLTv+8J_=n2-zOOd5fqwrNSvF7Ro1EyRyBBNb_8w@mail.gmail.com> <20170619.234819.333574326143678552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Lucas Bates <lucasb@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jiri Pirko <jiri@resnulli.us>, Roman Mashak <mrv@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36810 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750772AbdFTENx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 00:13:53 -0400
Received: by mail-wm0-f67.google.com with SMTP id d17so20486374wme.3
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 21:13:52 -0700 (PDT)
In-Reply-To: <20170619.234819.333574326143678552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 19, 2017 at 8:48 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Mon, 19 Jun 2017 16:37:29 -0700
>
>> Hi,
>>
>> On Fri, Jun 16, 2017 at 2:22 PM, Lucas Bates <lucasb@mojatatu.com> wrote:
>>> Apologies for sending this as one big patch. I've been sitting on this a little
>>> too long, but it's ready and I wanted to get it out.
>>>
>>> There are a limited number of tests to start - I plan to add more on a regular
>>> basis.
>>>
>>> Lucas Bates (1):
>>>   selftests: Introduce tc testsuite
>>
>> Nice work!
>>
>> Is there any particular reason you want to put these tests in kernel tree
>> especially tools/testing/selftests/ ?
>
> Yeah, it would be absolutely terrible if we had more tests in the
> kernel selftests area for networking.
>
> More seriously, we need more, not less, tests in the kernel networking
> selftests directory.
>
> It doesn't belong in iproute2 because we want a place to put things
> that automatically get tested when someone makes kernel changes and
> can be integrated into the kernel development workflow.
>
> I want as many tests as possible under there, so I'm really surprised
> that you're asking "why" tests are being added there.

I thought tools/testing/selftests/ is mainly for those tests close to
kernel ABI and API. What is the criteria for these tests? If any test
can fit in, we somehow would merge the whole LTP...

I definitely don't object more tests, I am just wondering if we should
put it to tools/testing/selftests/ or host it somewhere else.
