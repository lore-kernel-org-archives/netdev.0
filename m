From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] Avoid gettimeofday when not needed
Date: 31 Mar 2004 15:53:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331135325.GA62402@colin2.muc.de>
References: <200403311201.i2VC13D19579@zero.aec.at> <406AB7F6.6010805@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Wed, 31 Mar 2004 15:53:25 +0200
To: P@draigBrady.com
Content-Disposition: inline
In-Reply-To: <406AB7F6.6010805@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 31, 2004 at 01:22:14PM +0100, P@draigBrady.com wrote:
> Andi Kleen wrote:
> >This patch implements an optimization I proposed a long time 
> >ago. gettimeofday can be quite costly and it currently is 
> >on the fast path of every packet. Normally the packet time stamp
> >is not needed (e.g. TCP doesn't use it), except for tcpdump
> >and a few applications.
> 
> Will this work for apps that don't use a seperate syscall
> to get the timestamp. Like CONFIG_PACKET_MMAP for e.g?

The mmap will enable the time stamp, until the socket is closed.

-Andi
