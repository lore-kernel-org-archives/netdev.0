From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/8] netpoll: various bugfixes
Date: Thu, 11 Aug 2005 19:41:11 -0700 (PDT)
Message-ID: <20050811.194111.41635499.davem@davemloft.net>
References: <1.502409567@selenic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.com, ak@suse.de, jmoyer@redhat.com, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, mingo@elte.hu, john.ronciak@intel.com,
        rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mpm@selenic.com
In-Reply-To: <1.502409567@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Thu, 11 Aug 2005 21:18:28 -0500

> This patch series cleans up a few outstanding bugs in netpoll:
> 
> - two bugfixes from Jeff Moyer's netpoll bonding
> - a tweak to e1000's netpoll stub
> - timeout handling for e1000 with carrier loss
> - prefilling SKBs at init
> - a fix-up for a race discovered in initialization
> - an unused variable warning
> 
> This patch set was tested over repeated rebooting with both tg3 and
> e1000 and random cable disconnection, with and without SMP and
> preempt. Please apply.

All applied, thanks a lot for putting this patch set together.

I'll push this to Linus after some smoke testing.
