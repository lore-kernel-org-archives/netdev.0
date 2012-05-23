From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Wed, 23 May 2012 07:08:38 +0200
Message-ID: <1337749718.3361.1671.camel@edumazet-glaptop>
References: <1337742123.14538.175.camel@ymzhang.sh.intel.com>
	 <20120522.232310.911242148705021745.davem@davemloft.net>
	 <1337743841.14538.178.camel@ymzhang.sh.intel.com>
	 <20120522.234920.1047532847473945281.davem@davemloft.net>
	 <1337748069.14538.181.camel@ymzhang.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kunx.jiang@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:50642 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958Ab2EWFIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 01:08:44 -0400
In-Reply-To: <1337748069.14538.181.camel@ymzhang.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-23 at 12:41 +0800, Yanmin Zhang wrote:
> We did test it. But it's hard to reproduce it. We hit it the issue
> for a couple of times when running MTBF testing on Android smart phone.
> Mostly, it happens after MTBF runs for more than 12 hours. To releasing
> the product, MTBF testing should run for hundreds of hours. This bug
> blocks it.
> 

I have an idea how to trigger this in my test machine.

> We would submit it formally and also run more testing.
> 
> Sorry for taking you too much time.

Hey, you fix a bug, take your time and dont worry.

Thanks
