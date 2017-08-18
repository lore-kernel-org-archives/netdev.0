From: Joel Fernandes <joelaf@google.com>
Subject: Re: [PATCH RFC v2 3/5] samples/bpf: Fix inline asm issues building
 samples on arm64
Date: Thu, 17 Aug 2017 23:55:38 -0700
Message-ID: <CAJWu+orAs9X+sj6NBUEgvo5NzNCW2g=AR=K-u4Mn81VMmXB=2w@mail.gmail.com>
References: <20170807130602.31785-4-joelaf@google.com> <20170807.112840.395506747161262549.davem@davemloft.net>
 <CAJWu+orPBSozHo6PDnvg9+RzmYVO=rwwNZk45kHFsBJmy-3A-Q@mail.gmail.com> <20170808.203540.2238751604302920304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Chenbo Feng <fengc@google.com>,
        Alison Chaiken <alison@she-devel.com>,
        Juri Lelli <Juri.Lelli@arm.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "open list:BPF (Safe dynamic programs and tools)"
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170808.203540.2238751604302920304.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 8, 2017 at 8:35 PM, David Miller <davem@davemloft.net> wrote:
> From: Joel Fernandes <joelaf@google.com>
> Date: Mon, 7 Aug 2017 18:20:49 -0700
>
>> On Mon, Aug 7, 2017 at 11:28 AM, David Miller <davem@davemloft.net> wrote:
>>> The amount of hellish hacks we are adding to deal with this is getting
>>> way out of control.
>>
>> I agree with you that hellish hacks are being added which is why it
>> keeps breaking. I think one of the things my series does is to add
>> back inclusion of asm headers that were previously removed (that is
>> the worst hellish hack in my opinion that existing in mainline). So in
>> that respect my patch is an improvement and makes it possible to build
>> for arm64 platforms (which is currently broken in mainline).
>
> Yeah that is a problem.
>
> Perhaps another avenue of attack is to separate "type" header files from
> stuff that has functiond declarations and inline assembler code.

I was thinking that's probably a huge undertaking if you meant doing
the above for every arch?

Also another way could be to modify clang to ignore inline asm
directives during compilation? Do you have any comments about such
approach?

thanks,

-Joel
