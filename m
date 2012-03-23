From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fix possible overrun and simplify interrupt
 name field creation
Date: Thu, 22 Mar 2012 23:34:26 -0400 (EDT)
Message-ID: <20120322.233426.51094636300419378.davem@davemloft.net>
References: <17d93e9eb16cbad75b20cdbcaf38f268260d6fd5.1332010469.git.joe@perches.com>
	<20120321.223457.641438956547942596.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sandeep.kumar@freescale.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120321.223457.641438956547942596.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 21 Mar 2012 22:34:57 -0400 (EDT)

> From: Joe Perches <joe@perches.com>
> Date: Sat, 17 Mar 2012 12:05:38 -0700
> 
>> Space allocated for int_name_<foo> is unsufficient for
>> maximal device name, expand it.
>> 
>> Code to create int_name_<foo> is obscure, simplify it
>> by using sprintf.
>> 
>> Found by looking for unnecessary \ line continuations.
>> Uncompiled, untested.
>> 
>> Signed-off-by: Joe Perches <joe@perches.com>
> 
> Can a gianfar expert please review and test this patch?

If you gianfar guys don't show a sign of life in the next 24 hours I'm
just going to apply Joe's patch as-is.  I refuse to just let it rot in
patchwork like this.

And then you don't get to complain if his change breaks your driver
because I asked multiple times for testing and/or review.
