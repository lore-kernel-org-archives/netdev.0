From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: Re: [PATCH 00/12] radix-tree: split out struct radix_tree_root out to <linux/radix-tree-root.h>
Date: Mon, 9 Oct 2017 14:58:58 +0900
Message-ID: <CAK7LNAQrtikienLa+HXtnXmwCrTEQSnqU0Ne-BrFvKpaFMUxqQ@mail.gmail.com>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com> <20171008185233.GF25829@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ian Abbott <abbotti@mev.co.uk>, Ingo Molnar <mingo@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-cachefs@redhat.com, linux-sh@vger.kernel.org,
        Rodrigo Vivi <rodrigo.vivi@intel.com>,
        dri-devel <dri-devel@lists.freedesktop.org>,
        David Airlie <airlied@linux.ie>, linux-rdma@vger.kernel.org,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Tariq Toukan <tariqt@mellanox.com>,
        Rich Felker <dalias@libc.org>,
        Jani Nikula <jani.nikula@linux.intel.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        intel-gfx@lists.freedesktop.org,
        Yishai Hadas <yishaih@mellanox.com>,
        Joonas L
To: Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171008185233.GF25829@mtr-leonro.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2017-10-09 3:52 GMT+09:00 Leon Romanovsky <leonro@mellanox.com>:
> On Mon, Oct 09, 2017 at 01:10:01AM +0900, Masahiro Yamada wrote:
>
> <...>
>>
>> By splitting out the radix_tree_root definition,
>> we can reduce the header file dependency.
>>
>> Reducing the header dependency will help for speeding the kernel
>> build, suppressing unnecessary recompile of objects during
>> git-bisect'ing, etc.
>
> If we judge by the diffstat of this series, there won't be any
> visible change in anything mentioned above.


Of course, judging by the diffstat is wrong.



-- 
Best Regards
Masahiro Yamada
