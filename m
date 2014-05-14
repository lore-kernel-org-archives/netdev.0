From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: Use a more standard macro for INET_ADDR_COOKIE
Date: Wed, 14 May 2014 16:08:45 -0400 (EDT)
Message-ID: <20140514.160845.214090653562722244.davem@redhat.com>
References: <1400038207.24350.83.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400038207.24350.83.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 13 May 2014 20:30:07 -0700

> Missing a colon on definition use is a bit odd so
> change the macro for the 32 bit case to declare an
> __attribute__((unused)) and __deprecated variable.
> 
> The __deprecated attribute will cause gcc to emit
> an error if the variable is actually used.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

This is fine, applied, thanks Joe.

Perhaps it would have been nicer to make the macros be initializers,
so that it still would look like a proper variable declaration at
the use sites:

	const __addrpair var = INET_ADDR_COOKIE(x, y, z);

or something like that.
