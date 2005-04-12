From: Olaf Kirch <okir@suse.de>
Subject: Re: Fw: throttling kernel messages: KERNEL: assertion (flags & MSG_PEEK) failed at net/ipv4/tcp.c (1282)
Date: Tue, 12 Apr 2005 22:39:50 +0200
Message-ID: <20050412203950.GA9964@suse.de>
References: <20050412114148.66283c58.rddunlap@osdl.org> <1113337130.3004.14.camel@krak.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: KOVACS Krisztian <hidden@balabit.hu>
Content-Disposition: inline
In-Reply-To: <1113337130.3004.14.camel@krak.odu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 12, 2005 at 10:18:50PM +0200, KOVACS Krisztian wrote:
>   I also hit these assertions today. In my case it was probably because
> of a slab corruption problem caused by the e100 driver. (I had
> CONFIG_DEBUG_SLAB enabled, so a lot of slab corruption messages appeared
> right before these assertion errors.)

Yes, we've seen these symptoms in various bug reports in various 2.6
versions, and after some debugging narrowed it down to an e100 driver
issue. It went away with 2.6.11 final.

>   After applying e100-napi-fixes.patch from 2.6.11-mm4 the problem semms
> to be gone.

Ah, I'll look into that one. Thanks for the pointer!

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
