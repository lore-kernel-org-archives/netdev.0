From: David Miller <davem@davemloft.net>
Subject: Re: severe regression in alx ethernet driver
Date: Wed, 25 Nov 2015 23:10:08 -0500 (EST)
Message-ID: <20151125.231008.347752016459161329.davem@davemloft.net>
References: <20151123.111610.2054291192576855643.davem@davemloft.net>
	<20151124160739.GG38006@redhat.com>
	<20151125224708.GA1640@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, ldap.tester@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151125224708.GA1640@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 25 Nov 2015 23:47:08 +0100

> Jarod Wilson <jarod@redhat.com> :
> [...]
>> They do at least have a signed-off-by in the patches attached to the bug,
>> so I'm working on touching up the descriptions and formatting, regression
>> testing them on my laptop that has an alx-driven E2200 in it (which isn't
>> affected by this bug), and then I can ship them up for proper review.
> 
> You can forget the last refill-me-harder patch and save a roundtrip.
> The driver should 1) prohibit holes in its receive ring, 2) allocate before
> pushing data up in the stack and 3) drop packets when it can't allocate a
> fresh buffer.

+1
