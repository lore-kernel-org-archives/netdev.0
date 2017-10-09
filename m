From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: Re: [PATCH 10/12] net/mlx4: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
Date: Mon, 9 Oct 2017 14:56:56 +0900
Message-ID: <CAK7LNARAhAaO+YjqXyBbi=-udCu8zzGnLMsoVNdkSXtXPuMKsA@mail.gmail.com>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
 <1507479013-5207-11-git-send-email-yamada.masahiro@socionext.com>
 <20171008.100013.2081721941420989813.davem@davemloft.net> <CAK7LNAQ1BeSb14poieRU4uMsnsEHPNL2zSNtWi1TGN=YrK_8jA@mail.gmail.com>
 <20171008185529.GG25829@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ian Abbott <abbotti@mev.co.uk>, Ingo Molnar <mingo@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-rdma@vger.kernel.org, yishaih@mellanox.com,
        tariqt@mellanox.com, netdev@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171008185529.GG25829@mtr-leonro.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2017-10-09 3:55 GMT+09:00 Leon Romanovsky <leon@kernel.org>:
> On Mon, Oct 09, 2017 at 02:29:15AM +0900, Masahiro Yamada wrote:
>> 2017-10-09 2:00 GMT+09:00 David Miller <davem@davemloft.net>:
>> > From: Masahiro Yamada <yamada.masahiro@socionext.com>
>> > Date: Mon,  9 Oct 2017 01:10:11 +0900
>> >
>> >> The headers
>> >>  - include/linux/mlx4/device.h
>> >>  - drivers/net/ethernet/mellanox/mlx4/mlx4.h
>> >> require the definition of struct radix_tree_root, but do not need to
>> >> know anything about other radix tree stuff.
>> >>
>> >> Include <linux/radix-tree-root.h> instead of <linux/radix-tree.h> to
>> >> reduce the header dependency.
>> >>
>> >> While we are here, let's add missing <linux/radix-tree.h> where
>> >> radix tree accessors are used.
>> >>
>> >> Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
>> >
>> > Honestly this makes things more complicated.
>>
>>
>> The idea is simple; include necessary headers explicitly.
>>
>> Putting everything into one common header
>> means most of C files are forced to parse unnecessary headers.
>
> It is neglected, only first caller will actually parse that header file,
> other callers will check the #ifndef pragma without need to reparse the
> whole file.
>


You completely neglected the point of the discussion.

I am trying to not include unnecessary headers at all.




-- 
Best Regards
Masahiro Yamada
