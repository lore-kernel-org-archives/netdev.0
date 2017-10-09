From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: Re: [PATCH 10/12] net/mlx4: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
Date: Mon, 9 Oct 2017 21:02:55 +0900
Message-ID: <CAK7LNAQEUnLu8mc7o80DYfPrQgV4xW+7ehqRd1MJh=NsOTBDaw@mail.gmail.com>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
 <1507479013-5207-11-git-send-email-yamada.masahiro@socionext.com>
 <20171008.100013.2081721941420989813.davem@davemloft.net> <CAK7LNAQ1BeSb14poieRU4uMsnsEHPNL2zSNtWi1TGN=YrK_8jA@mail.gmail.com>
 <1507483942.11434.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ian Abbott <abbotti@mev.co.uk>, Ingo Molnar <mingo@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-rdma@vger.kernel.org, Yishai Hadas <yishaih@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507483942.11434.4.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2017-10-09 2:32 GMT+09:00 Joe Perches <joe@perches.com>:
> On Mon, 2017-10-09 at 02:29 +0900, Masahiro Yamada wrote:
>> The idea is simple; include necessary headers explicitly.
>
> Try that for kernel.h
>
> There's a reason aggregation of #includes is useful.
>

BTW, talking about <linux/kernel.h>, it is too much aggregation, isn't it?

It exceed 850 lines, and contains lots of unrelated stuff in one header.
Perhaps, it could be a good time to think about splitting?

For example, I see many trace_... things in it.

I wonder if linux/kernel.h is a good home for them, or a separate file.


-- 
Best Regards
Masahiro Yamada
