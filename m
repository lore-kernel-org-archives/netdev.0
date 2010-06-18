From: David Miller <davem@davemloft.net>
Subject: Re: BUG: double spinlock in "drivers/net/3c505.c"
Date: Thu, 17 Jun 2010 20:12:16 -0700 (PDT)
Message-ID: <20100617.201216.115931147.davem@davemloft.net>
References: <201006071517.28744.strakh@ispras.ru>
	<1276003605.3916.14.camel@lovely>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: strakh@ispras.ru, philb@gnu.org, craigs@ineluki.apana.org.au,
	tridge@nimbus.anu.edu.au, Alan.Cox@linux.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: chf.fritz@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1276003605.3916.14.camel@lovely>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Fritz <chf.fritz@googlemail.com>
Date: Tue, 08 Jun 2010 15:26:45 +0200

> On Mon, 2010-06-07 at 15:17 +0400, Alexander Strakh wrote: 
>> 	KERNEL_VERSION: 2.6.35-rc1
>>         SUBJECT: duble spinlock  in function elp_start_xmit
> 
> Not only in elp_start_xmit. This driver is for a pretty old and slow isa
> ethernet card and I think nobody cares. To quote a comment from the
> source: "[...] the concurrency protection is particularly awful".

Indeed, I spent some time trying to unravel the locking mess
for these call chains to check_3c505_dma() and it was just
too much to sanely cure.
