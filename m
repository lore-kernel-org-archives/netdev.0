From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH]: Tigon3 new NAPI locking v2
Date: Tue, 07 Jun 2005 20:11:12 +1000
Message-ID: <1118139072.2198.119.camel@hole.melbourne.sgi.com>
References: <20050603.122558.88474819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@oss.sgi.com>, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050603.122558.88474819.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-06-04 at 05:25, David S. Miller wrote:
> This version incorporates two bug fixes from Michael.
> 
> 1) Check the mailbox register for 0x1 while polling on the COMPLETE
>    state bit.
> 
> 2) Remove the BUG_ON() check in tg3_restart_ints(), it can legally and
>    harmlessly occur.
> 
> Point #2 may want some refinements, but this patch below is good
> enough for testing.

This patch seems to run well, so far without the lockup we saw
with the first version.  It really helps with irq fairness when
we have lots of tg3 and Fibre Channel HBA interrupts going to the
same CPU.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
