From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH - RFC] [1/5] 64-bit network statistics - generic net
Date: Sat, 05 Jul 2003 14:46:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F074739.9090006@candelatech.com>
References: <Pine.LNX.4.44.0307032005340.8468-100000@home.osdl.org> <200307051449.32934.jeffpc@optonline.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>,
   Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Andrew Morton <akpm@digeo.com>, Dave Jones <davej@codemonkey.org.uk>,
   Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Sipek <jeffpc@optonline.net>
In-Reply-To: <200307051449.32934.jeffpc@optonline.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Sipek wrote:

> Using KB would give us additional 10 bits (making the overflow at 4 TB.) I 
> don't really like the idea of using MB, but the underlying idea is the same - 
> 20 more bits, making the limit 4 PB.
> 
> What is the consensus on this way of solving the problem?

I guess it could be useful for something like ifconfig, but serious
applications will need more precision and should deal with wraps anyway
(even on 64-bits, in my opinion..why have to fix bugs in 10 years because
we were too lazy to take the 10 minutes to make it right now).

Ben


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
