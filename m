From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] fix HIPQUAD macro in kernel.h
Date: Thu, 8 Aug 2002 13:41:13 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020808134113.A2552@wotan.suse.de>
References: <20020808133112.E11828@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@redhat.com>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <owner-netdev@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
Content-Disposition: inline
In-Reply-To: <20020808133112.E11828@sunbeam.de.gnumonks.org>
List-Id: netdev.vger.kernel.org

On Thu, Aug 08, 2002 at 01:31:12PM +0200, Harald Welte wrote:
> Hi Dave!
> 
> Below is a fix for the HIPQUAD macro in kernel.h.  The macro is currently
> not endian-aware - it just assumes running on a little-endian machine.
> 
> If you don't like the #ifdefs in kernel.h, the macros could be moved into 
> include/linux/byteorder/.
> 
> Please apply, thanks

That change is wrong. IP address should be always in network order (=BE) 
while in kernel.

-Andi
