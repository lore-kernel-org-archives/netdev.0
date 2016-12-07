From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH]net:sched:release lock before tcf_dump_walker() normal
 return to avoid deadlock
Date: Tue, 6 Dec 2016 16:10:08 -0800
Message-ID: <CAM_iQpWHYszm0AEdxQJmn6M3rfDGTZkN0+aJNkS9Za1oP8H+xw@mail.gmail.com>
References: <CAEX1niWim7BSki6uRtihwbJ3Adw4Qwt8MR1aki8UA4_x7V9UTA@mail.gmail.com>
 <c2b3ff55-7636-4b38-ca06-54d5ff75f4bf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Feng Deng <cxdx2006@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        feng.deng@cortina-access.com, Roman Mashak <mrv@mojatatu.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35548 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751721AbcLGAKa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 19:10:30 -0500
In-Reply-To: <c2b3ff55-7636-4b38-ca06-54d5ff75f4bf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 6, 2016 at 5:50 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-12-06 12:36 AM, Feng Deng wrote:
>>
>> From: Feng Deng<cxdx2006@gmail.com>
>>
>> release lock before tcf_dump_walker() normal return to avoid deadlock
>>
>
> /Scratching my head.
>
> I am probably missing something obvious.
> What are the condition under which this deadlock will happen?
> Do you have a testcase we can try?

I don't even see a patch (tried Google too).
