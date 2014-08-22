From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH] net: ethernet: broadcom: bnx2x: Remove redundant #ifdef
Date: Fri, 22 Aug 2014 09:33:07 +0200
Message-ID: <87mwaxrnbg.fsf@rasmusvillemoes.dk>
References: <1408540489-1795-1-git-send-email-linux@rasmusvillemoes.dk>
	<20140821.213750.2151406448495608410.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ariel.elior@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140821.213750.2151406448495608410.davem@davemloft.net> (David
	Miller's message of "Thu, 21 Aug 2014 21:37:50 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> Date: Wed, 20 Aug 2014 15:14:49 +0200
>
>> Nothing defines _ASM_GENERIC_INT_L64_H, it is a weird way to check for
>> 64 bit longs, and u64 should be printed using %llx anyway.
>> 
>> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
>
> It's not correct and will warn on some platforms where "u64" is just
> a plain "unsigned long".
>
> Ie. all of those which use include/asm-generic/int-l64.h

Of which there are none; that file no longer exists (as I said, nothing
defines that macro). Please see 0c79a8e2 ("asm/types.h: Remove
include/asm-generic/int-l64.h") and 2a7930bd
("Documentation/printk-formats.txt: No casts needed for u64/s64").

Thanks,
Rasmus
