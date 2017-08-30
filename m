From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [GIT] Networking
Date: Wed, 30 Aug 2017 20:31:31 +0300
Message-ID: <87val5rmh8.fsf@kamboji.qca.qualcomm.com>
References: <20170815.175219.753462032002961032.davem@davemloft.net>
        <20170830094823.GA31503@amd> <87pobdt8qc.fsf@kamboji.qca.qualcomm.com>
        <20170830.101143.2305098064824357647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: pavel@ucw.cz, xiyou.wangcong@gmail.com,
        torvalds@linux-foundation.org, akpm@linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830.101143.2305098064824357647.davem@davemloft.net> (David
        Miller's message of "Wed, 30 Aug 2017 10:11:43 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Kalle Valo <kvalo@codeaurora.org>
> Date: Wed, 30 Aug 2017 17:45:31 +0300
>
>> Pavel Machek <pavel@ucw.cz> writes:
>> 
>>> Could we get this one in?
>>>
>>> wl1251 misses a spin_lock_init().
>>>
>>> https://www.mail-archive.com/netdev@vger.kernel.org/msg177031.html
>>>
>>> It seems pretty trivial, yet getting the backtraces is not nice.
>> 
>> It's in wireless-drivers-next and will be in 4.14-rc1:
>> 
>> https://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git/commit/?id=6e9aae179f290f1a44fce7ef8e9a8e2dd68ed1e4
>
> Is the bug only present in net-next?

AFAICS the bug was introduced by 9df86e2e702c6 back in 2010. If the bug
has been there for 7 years so waiting for a few more weeks should not
hurt.

And Pavel can also submit it to the stable release, it should apply
without problems as wl1251 doesn't have had that many patches during the
last few years (if ever).

-- 
Kalle Valo
