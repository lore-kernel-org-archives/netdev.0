From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] net: use designated initializers
Date: Sat, 17 Dec 2016 13:33:00 -0800
Message-ID: <CAGXu5j+rN7So6A2OXwnPz8Y8KtBrtsoYfAt4xMCc1MGE8Yf70A@mail.gmail.com>
References: <20161217005858.GA140223@beast> <20161217.115745.140164763267728629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
        linux-decnet-user@lists.sourceforge.net,
        Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161217.115745.140164763267728629.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 17, 2016 at 8:57 AM, David Miller <davem@davemloft.net> wrote:
> From: Kees Cook <keescook@chromium.org>
> Date: Fri, 16 Dec 2016 16:58:58 -0800
>
>> Prepare to mark sensitive kernel structures for randomization by making
>> sure they're using designated initializers. These were identified during
>> allyesconfig builds of x86, arm, and arm64, with most initializer fixes
>> extracted from grsecurity.
>>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>
> Applied, although "decnet: " would have been a much better
> subsystem prefix.

Thanks! Yeah, I had corrected that in my tree already in case there
was a v2 needed. I was working off an auto-splitting script that I
taught to guess at prefixes by looking at commit logs. It didn't work
very well. ;) We need another field in MAINTAINERS. :)

-Kees

-- 
Kees Cook
Nexus Security
