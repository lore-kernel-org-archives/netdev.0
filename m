From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: NULL pointer dereference in xt_register_target()
Date: Thu, 6 Sep 2012 22:27:22 +0800
Message-ID: <CAM_iQpVAZwKhZxLdk-BLMjnK3eX4DD_o9KvzuAoTttyxvmCsJA@mail.gmail.com>
References: <CAM_iQpVUZ50RYLUgEHbcm7ua996hgE7Gj-P-bWNJutuvm1nUoQ@mail.gmail.com>
	<1346860506.13121.148.camel@edumazet-glaptop>
	<20120905164831.GA21836@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter-devel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120905164831.GA21836@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 6, 2012 at 12:48 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Wed, Sep 05, 2012 at 05:55:06PM +0200, Eric Dumazet wrote:
>> On Wed, 2012-09-05 at 23:43 +0800, Cong Wang wrote:
>> > Hi, folks,
>> >
>> > The latest net-next tree can't boot due to a NULL ptr def
>> > bug in the kernel, the full backtrack is:
>> >
>> > http://img1.douban.com/view/photo/photo/public/p1697139550.jpg
>> >
>> > the kernel .config file is:
>> >
>> > http://pastebin.com/9YTnkqKN
>> >
>> > I don't have time to look into the issue. If you need other info,
>> > please let me know.
>>
>> It seems xt_nat_init() is called before xt_init(), so xt array is not
>> yet setup.
>
> I have enqueued the following patch to fix this:
>
> http://1984.lsi.us.es/git/nf-next/commit/?id=00545bec9412d130c77f72a08d6c8b6ad21d4a1
> e
> commit 00545bec9412d130c77f72a08d6c8b6ad21d4a1e
> Author: Pablo Neira Ayuso <pablo@netfilter.org>
> Date:   Wed Sep 5 18:24:55 2012 +0200
>
>     netfilter: fix crash during boot if NAT has been compiled built-in
>

Yeah, this indeed fixes the bug.

Please push it to net-next as soon as possible?

Thanks!
