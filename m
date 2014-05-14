From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Use a more standard macro for INET_ADDR_COOKIE
Date: Wed, 14 May 2014 16:48:05 -0400 (EDT)
Message-ID: <20140514.164805.1312198151357839253.davem@davemloft.net>
References: <1400038207.24350.83.camel@joe-AO725>
	<20140514.160845.214090653562722244.davem@redhat.com>
	<1400100249.30384.32.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400100249.30384.32.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 14 May 2014 13:44:09 -0700

> On Wed, 2014-05-14 at 16:08 -0400, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Tue, 13 May 2014 20:30:07 -0700
>> 
>> > Missing a colon on definition use is a bit odd so
>> > change the macro for the 32 bit case to declare an
>> > __attribute__((unused)) and __deprecated variable.
>> > 
>> > The __deprecated attribute will cause gcc to emit
>> > an error if the variable is actually used.
>> > 
>> > Signed-off-by: Joe Perches <joe@perches.com>
>> 
>> This is fine, applied, thanks Joe.
>> 
>> Perhaps it would have been nicer to make the macros be initializers,
>> so that it still would look like a proper variable declaration at
>> the use sites:
>> 
>> 	const __addrpair var = INET_ADDR_COOKIE(x, y, z);
>> 
>> or something like that.
> 
> Maybe so, but there's no way to add an __attribute__
> before the = sign for the 32 bit case like that without
> another #define and it would then always require
> initialization too.

Good point.
