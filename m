From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Thu, 27 Nov 2003 22:33:48 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031127223348.G25015@flint.arm.linux.org.uk>
References: <1069934643.2393.0.camel@teapot.felipe-alfaro.com> <20031127.210953.116254624.yoshfuji@linux-ipv6.org> <20031127194602.A25015@flint.arm.linux.org.uk> <20031128.045413.133305490.yoshfuji@linux-ipv6.org> <20031127200041.B25015@flint.arm.linux.org.uk> <1069970770.2138.10.camel@teapot.felipe-alfaro.com> <20031127221928.F25015@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>,
        "YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B" <yoshfuji@linux-ipv6.org>,
        davem@redhat.com,
        Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031127221928.F25015@flint.arm.linux.org.uk>; from rmk+lkml@arm.linux.org.uk on Thu, Nov 27, 2003 at 10:19:28PM +0000
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 27, 2003 at 10:19:28PM +0000, Russell King wrote:
> Note: we should really fix the generic strncpy() - there are places in
> the kernel source which rely on the x86 strncpy() behaviour today (eg,
> binfmt_*.c core file generation.)

Sorry, bad example.  Hmm, from a glance around, it seems that all of
the places which use strncpy() implicitly zero the buffer prior to
using strncpy().

This means that the x86 strncpy is doing unnecessary zeroing.  I do
remember Alan complaining about the last set of strlcpy() stuff
introducing information leaks - maybe those got fixed though.

Ok, I don't know where the kernel stands on this issue anymore.
Can someone definitively provide a statement of exactly what the
kernel expects of strncpy() ?

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
