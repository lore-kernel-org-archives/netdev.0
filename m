From: James Morris <jmorris@intercode.com.au>
Subject: Re: link error building kernel with gcc-3.3
Date: Thu, 15 May 2003 15:38:15 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0305151536280.12417-100000@excalibur.intercode.com.au>
References: <20030514202941.39519.qmail@web40503.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Alex Davis <alex14641@yahoo.com>
In-Reply-To: <20030514202941.39519.qmail@web40503.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 May 2003, Alex Davis wrote:

> I got the following linking 2.4.21rc1:
> 
> net/network.o(.text+0xdcb7): In function `rtnetlink_rcv':
> : undefined reference to `rtnetlink_rcv_skb'
> make: *** [vmlinux] Error 1
> 
> Removing '__inline__' from the definition of rtnetlink_rcv_skb
> in net/core/rtnetlink.c fixed the problem. 
> 
> Note: this error also occurs in 2.4.21rc2-ac2

I wonder, does this mean that the compiler failed to inline the function?

Removing __inline__ is not the correct solution.


- James
-- 
James Morris
<jmorris@intercode.com.au>
