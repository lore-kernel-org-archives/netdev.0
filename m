From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: Re: pci-skeleton duplex check
Date: Sat, 14 Dec 2002 16:14:46 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021214161446.B23020@flint.arm.linux.org.uk>
References: <200212141428.TAA32351@WS0005.indiatimes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Richardson <mcr@sandelman.ottawa.on.ca>, netdev@oss.sgi.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: arun4linux <arun4linux@indiatimes.com>
Content-Disposition: inline
In-Reply-To: <200212141428.TAA32351@WS0005.indiatimes.com>; from arun4linux@indiatimes.com on Sat, Dec 14, 2002 at 08:05:30PM +0530
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Dec 14, 2002 at 08:05:30PM +0530, arun4linux wrote:
> Interfaces should NEVER change in patch level versions.
> Just *DO NOT DO IT*.
> I do agree on this.

Rubbish.

Think about what you've just said.  Patch level version changes are
things like 2.5.43 to 2.5.44 or 2.4.19 to 2.4.20.

You are saying that we shouldn't change any interfaces between (eg)
2.5.43 and 2.5.44, but we should change every interface we want to
change between 2.4.15 and 2.5.0.

This is obviously completely bogus.  2.5 is a _development_ tree.
Everyone should expect anything, including interfaces to change
between each development patch level.

> This is a common complaint about linux kernel developers. And this always
> gives an insecure feeling  :-) for the device driver or kernel module
> programmers. 

If interfaces are changed without extremely good reason between two
_stable_ patch level versions, that would be a bug.

> This was one of the issues in my earlier company/work and they have
> gone for another OS.

Was the problem against a stable kernel version?  Did you report the
problem when you found it?  Was there a response?

Unless you have done at least the above, I, for one, have very little
sympathy.

-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html
