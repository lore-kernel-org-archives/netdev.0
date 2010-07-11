From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Sat, 10 Jul 2010 19:52:10 -0700 (PDT)
Message-ID: <20100710.195210.200371025.davem@davemloft.net>
References: <20100707.174522.148565561.davem@davemloft.net>
	<20100707.181847.62350965.davem@davemloft.net>
	<1278562423.1712.43.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@suse.de
To: joe@perches.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1278562423.1712.43.camel@Joe-Laptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 07 Jul 2010 21:13:42 -0700

> On Wed, 2010-07-07 at 18:18 -0700, David Miller wrote:
>> It looks like there are just a hand-ful of cases, so maybe we can tweak
>> them by hand.  For example, in the sym53c8xx_2 driver bits we can replace
>> the NULL labels passed to sym_print_msg() with a real string and therefore
>> remove the "" case.
>> 
>> Joe, any better ideas?
> 
> You're right there are just a few cases where dev_info
> is uses as a preface for a hex_dump style display.
> 
> Maybe it'd be OK to simply add a trailing space to the
> preface and remove any leading spaces from the subsequent
> initial printks.
> 
> dev_info(dev, " ");

That might work.

The sym53c8xx_2 doesn't even need this, like I said, you could
just remove the NULL 'label' argument cases and then have that
bit cured.

Could you take a stab at this and the other scsi bits that
trigger this warning?

Thanks Joe!
