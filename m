From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCH] net/sched: reset block pointer in tcf_block_put()
Date: Tue, 15 Aug 2017 16:48:52 +0300
Message-ID: <2866a53a-5aed-1e22-2bc4-5a5062db9870@yandex-team.ru>
References: <150235751251.493255.14955523507789154918.stgit@buzz>
 <CAM_iQpX=XLheuuBk_kAa+jHO-e16hnzavHhzHJ4EYWwpjGFzMg@mail.gmail.com>
 <ad81a570-dff5-7c74-170e-70e764778cba@yandex-team.ru>
 <CAM_iQpUJRAn75aBrBzoWABt21tgTYLo1MPNQwTUa9BSs0QXyaQ@mail.gmail.com>
 <7267faab-c089-e60b-0696-3734f801c1ba@yandex-team.ru>
 <CAM_iQpX2=Fg8JN1c8qnLPae34hsYEG7xUKZ-RoppBnVoBDb+6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1g.cmail.yandex.net ([87.250.241.190]:39002 "EHLO
        forwardcorp1g.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751482AbdHONsy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 09:48:54 -0400
In-Reply-To: <CAM_iQpX2=Fg8JN1c8qnLPae34hsYEG7xUKZ-RoppBnVoBDb+6g@mail.gmail.com>
Content-Language: ru-RU
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 15.08.2017 00:15, Cong Wang wrote:
> On Mon, Aug 14, 2017 at 5:59 AM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
>>
>> This should work, I suppose.
>>
>> But this approach requires careful review for all qdisc, mine is completely
>> mechanical.
> 
> Well, we don't have many classful qdisc's. Your patch actually
> touches more qdisc's than mine, because you change an API, so
> it is slightly harder to backport. ;)
> 

Ok, I've fixed this right in qdiscs: [PATCH] net_sched: reset pointers to tcf blocks in classful qdiscs' destructors
