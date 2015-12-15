From: David Miller <davem@davemloft.net>
Subject: Re: Information leak in llcp_sock_bind/llcp_raw_sock_bind
Date: Tue, 15 Dec 2015 15:58:56 -0500 (EST)
Message-ID: <20151215.155856.467616191891653108.davem@davemloft.net>
References: <CACT4Y+ZnZ2EcZwc6T5LZ1YR2zC8+6aFT_JFYb_LeegnB6tmESw@mail.gmail.com>
	<20151215.154851.2132284113916223057.davem@davemloft.net>
	<CACT4Y+a804iMbkA+kWdYfOPYGQz61ZCRVqKOdDBYtSM=FQ2cYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: syzkaller@googlegroups.com, lauro.venancio@openbossa.org,
	aloisio.almeida@openbossa.org, sameo@linux.intel.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, edumazet@google.com, kcc@google.com,
	glider@google.com, sasha.levin@oracle.com
To: dvyukov@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+a804iMbkA+kWdYfOPYGQz61ZCRVqKOdDBYtSM=FQ2cYQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 15 Dec 2015 21:55:37 +0100

> I've seen a kernel address at least in pptp_bind,

We're not talking about pptp_bind.

We're talking about llcp_{,raw}_sock_bind().

If your hex dump doesn't show it, don't report anything unless you are
absolutely sure via code inspection that there could be a leak.  And
in that case make it perfectly clear exactly how that can happen.

I am generally unimpressed with your reports half of the time,
and just a small amount of extra effort would extraordinarily
improve the quality of the things your post.

Thanks.

> So it is almost impossible to prove that a PC cannot be leaked.

You can't show that anything is actually being leaked in this specific
case, period.
