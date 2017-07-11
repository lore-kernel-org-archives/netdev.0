From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch] mqueue: fix netlink sock refcnt and skb refcnt
Date: Tue, 11 Jul 2017 12:58:41 -0700
Message-ID: <CAM_iQpW35zDk8a=RDGPjUO27_JzYv+YqKhmAYKMDATN2L-4LSQ@mail.gmail.com>
References: <1499663303-4514-1-git-send-email-xiyou.wangcong@gmail.com> <CA+55aFzYK_14nuyjrvyxDoSS2rvhcCxOpdbLKqNGuRvwuON9jA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Manfred Spraul <manfred@colorfullife.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzYK_14nuyjrvyxDoSS2rvhcCxOpdbLKqNGuRvwuON9jA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 10, 2017 at 11:09 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> This thing is definitely not cc'd to the right people:
>
> On Sun, Jul 9, 2017 at 10:08 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Manfred Spraul <manfred@colorfullife.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> Unlike your previous patch, this seems to be more of a generic netlink
> interface issue, so you should primarily talk to the networking
> people, I'm not sure it makes much sense to cc me/Andrew/Manfred.
>

OK, actually this patch is not needed, because we only send notification
once, although the code itself does need some cleanup.

Sorry for the noise.
