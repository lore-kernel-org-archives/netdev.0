From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: don't copy over empty attribute data
Date: Sun, 26 Oct 2014 22:03:50 -0400 (EDT)
Message-ID: <20141026.220350.2098346782596904995.davem@davemloft.net>
References: <54471438.1040907@oracle.com>
	<20141022.021508.2011745433893496421.davem@davemloft.net>
	<544D849A.4040304@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.ryabinin@samsung.com, pablo@netfilter.org, mschmidt@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <544D849A.4040304@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Sun, 26 Oct 2014 19:32:42 -0400

> How so? GCC states clearly that you should *never* pass a NULL
> pointer there:
> 
> "The pointers passed to memmove (and similar functions in <string.h>) must
> be non-null even when nbytes==0" (https://gcc.gnu.org/gcc-4.9/porting_to.html).
> 
> Even if it doesn't dereference it, it can break somehow in a subtle way. Leaving
> the kernel code assuming that gcc (or any other compiler) would always behave
> the same in a situation that shouldn't occur.

Show me a legal way in which one could legally dereference the pointer
when length is zero, and I'll entertain this patch.
