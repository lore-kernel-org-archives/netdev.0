From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/1] Introduction of the tc tests
Date: Mon, 19 Jun 2017 23:48:19 -0400 (EDT)
Message-ID: <20170619.234819.333574326143678552.davem@davemloft.net>
References: <1497648155-25521-1-git-send-email-lucasb@mojatatu.com>
        <CAM_iQpUxfGrLTv+8J_=n2-zOOd5fqwrNSvF7Ro1EyRyBBNb_8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucasb@mojatatu.com, netdev@vger.kernel.org,
        stephen@networkplumber.org, jiri@resnulli.us, mrv@mojatatu.com,
        jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47908 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751689AbdFTDsX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 23:48:23 -0400
In-Reply-To: <CAM_iQpUxfGrLTv+8J_=n2-zOOd5fqwrNSvF7Ro1EyRyBBNb_8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 19 Jun 2017 16:37:29 -0700

> Hi,
> 
> On Fri, Jun 16, 2017 at 2:22 PM, Lucas Bates <lucasb@mojatatu.com> wrote:
>> Apologies for sending this as one big patch. I've been sitting on this a little
>> too long, but it's ready and I wanted to get it out.
>>
>> There are a limited number of tests to start - I plan to add more on a regular
>> basis.
>>
>> Lucas Bates (1):
>>   selftests: Introduce tc testsuite
> 
> Nice work!
> 
> Is there any particular reason you want to put these tests in kernel tree
> especially tools/testing/selftests/ ?

Yeah, it would be absolutely terrible if we had more tests in the
kernel selftests area for networking.

More seriously, we need more, not less, tests in the kernel networking
selftests directory.

It doesn't belong in iproute2 because we want a place to put things
that automatically get tested when someone makes kernel changes and
can be integrated into the kernel development workflow.

I want as many tests as possible under there, so I'm really surprised
that you're asking "why" tests are being added there.
