From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: kernel BUG at net/unix/garbage.c:149!"
Date: Fri, 26 Aug 2016 22:24:26 +0200
Message-ID: <1fbcb2c7-f004-4f2d-634e-a807dd5ec984@stressinduktion.org>
References: <57BDAE06.1040400@kyup.com>
 <9dde3145-9128-ffef-1b84-e3bd429dd4e8@stressinduktion.org>
 <CAJFSNy6rEpy7JcimW_jiOkgtWtDQgMaQJhcFHvRqgj92HibAvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: mszeredi@redhat.com,
        "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
To: Nikolay Borisov <kernel@kyup.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJFSNy6rEpy7JcimW_jiOkgtWtDQgMaQJhcFHvRqgj92HibAvQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25.08.2016 01:30, Nikolay Borisov wrote:
> On Thu, Aug 25, 2016 at 12:40 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On 24.08.2016 16:24, Nikolay Borisov wrote:
> [SNIP]
>>
>> One commit which could have to do with that is
>>
>> commit fc64869c48494a401b1fb627c9ecc4e6c1d74b0d
>> Author: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Date:   Wed May 18 19:19:27 2016 +0300
>>
>>     net: sock: move ->sk_shutdown out of bitfields.
>>
>> but that is only a wild guess.
>>
>> Which unix_sock did you extract specifically in the url you provided? In
>> unix_notinflight we are specifically checking an unix domain socket that
>> is itself being transferred over another af_unix domain socket and not
>> the unix domain socket being released at this point.
> 
> So this is the state of the socket that is being passed to
> unix_notinflight. I have a complete crashdump so if you need more info
> to diagnose it I'm happy to provide it. I'm not too familiar with the
> code in question so I will need a bit of time to grasp what actually
> is happening.

Would probably be helpful. I couldn't spot anything so far
unfortunately. Also moving sockets over sockets which get closed
inflight seemed to work fine.
