From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v2 3/5] samples/bpf: Fix inline asm issues building
 samples on arm64
Date: Tue, 08 Aug 2017 20:35:40 -0700 (PDT)
Message-ID: <20170808.203540.2238751604302920304.davem@davemloft.net>
References: <20170807130602.31785-4-joelaf@google.com>
        <20170807.112840.395506747161262549.davem@davemloft.net>
        <CAJWu+orPBSozHo6PDnvg9+RzmYVO=rwwNZk45kHFsBJmy-3A-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, fengc@google.com,
        alison@she-devel.com, Juri.Lelli@arm.com, ast@kernel.org,
        daniel@iogearbox.net, netdev@vger.kernel.org
To: joelaf@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJWu+orPBSozHo6PDnvg9+RzmYVO=rwwNZk45kHFsBJmy-3A-Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joel Fernandes <joelaf@google.com>
Date: Mon, 7 Aug 2017 18:20:49 -0700

> On Mon, Aug 7, 2017 at 11:28 AM, David Miller <davem@davemloft.net> wrote:
>> The amount of hellish hacks we are adding to deal with this is getting
>> way out of control.
> 
> I agree with you that hellish hacks are being added which is why it
> keeps breaking. I think one of the things my series does is to add
> back inclusion of asm headers that were previously removed (that is
> the worst hellish hack in my opinion that existing in mainline). So in
> that respect my patch is an improvement and makes it possible to build
> for arm64 platforms (which is currently broken in mainline).

Yeah that is a problem.

Perhaps another avenue of attack is to separate "type" header files from
stuff that has functiond declarations and inline assembler code.
