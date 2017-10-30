From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] net: tipc: Convert timers to use timer_setup()
Date: Mon, 30 Oct 2017 14:07:35 -0700
Message-ID: <CAGXu5jL=4-8ZzkF82tEo09fBdkVRKQ=BWdj-dHTtsz-3o-AsHA@mail.gmail.com>
References: <20171024084637.GA23944@beast> <AM4PR07MB1714904E90C690AD11257B189A470@AM4PR07MB1714.eurprd07.prod.outlook.com>
 <CAGXu5jKzCDeW2UaEB4EK2uy4wjC6TidFQtSTj0-F2jLYgZXq0A@mail.gmail.com> <AM4PR07MB17145765E885BE86ED56C9609A590@AM4PR07MB1714.eurprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Ying Xue <ying.xue@windriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "tipc-discussion@lists.sourceforge.net"
        <tipc-discussion@lists.sourceforge.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM4PR07MB17145765E885BE86ED56C9609A590@AM4PR07MB1714.eurprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 30, 2017 at 2:57 AM, Jon Maloy <jon.maloy@ericsson.com> wrote:
>
>
>> -----Original Message-----
>> From: keescook@google.com [mailto:keescook@google.com] On Behalf Of
>> Kees Cook
>> Sent: Friday, October 27, 2017 06:58
>> To: Jon Maloy <jon.maloy@ericsson.com>
>> Cc: David S. Miller <davem@davemloft.net>; Ying Xue
>> <ying.xue@windriver.com>; netdev@vger.kernel.org; tipc-
>> discussion@lists.sourceforge.net; linux-kernel@vger.kernel.org
>> Subject: Re: [PATCH] net: tipc: Convert timers to use timer_setup()
>>
>> On Tue, Oct 24, 2017 at 11:44 AM, Jon Maloy <jon.maloy@ericsson.com>
>> wrote:
>> > NAK. It doesn't sound like a good idea to send this to net. Especially since
>> one of these timers has already been refactored in net-next.
>>
>> Hi! I'm not sure what you mean about the one timer issue. I don't see any
>> use of timer_setup() in net/tipc (and no recent conversions to the older
>> setup_timer() API). What's the preferred path for landing this API conversion
>> in net/tipc/?
>>
>> And, just to note, these changes are almost entirely mechanical. The only
>> "special" case is in tipc_sk_timeout() where the argument needs to be
>> slightly adjusted to fetch the tsk from the sk again.
>
> I am referring to commit 0d5fcebf3c37 ("tipc: refactor tipc_sk_timeout() function") which is in "net-next" but not yet in "net".
> I guess David M is the one who decides whether you deliver to net or net-next, but in the former case you will have to wait until David merges in the above commit, and then add your change again.

Ah, thanks, I see the change now. These patches passed in the night,
it seems. I've sent a v2 now for net-next.

Thanks!

-Kees

-- 
Kees Cook
Pixel Security
