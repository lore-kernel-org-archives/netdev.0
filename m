From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Thu, 27 Nov 2003 19:46:02 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031127194602.A25015@flint.arm.linux.org.uk>
References: <20031127.173320.19253188.yoshfuji@linux-ipv6.org> <20031127025921.3fed8dd4.davem@redhat.com> <1069934643.2393.0.camel@teapot.felipe-alfaro.com> <20031127.210953.116254624.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: felipe_alfaro@linuxmail.org, davem@redhat.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20031127.210953.116254624.yoshfuji@linux-ipv6.org>; from yoshfuji@linux-ipv6.org on Thu, Nov 27, 2003 at 09:09:53PM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 27, 2003 at 09:09:53PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B wrote:
> In article <1069934643.2393.0.camel@teapot.felipe-alfaro.com> (at Thu, 27 Nov 2003 13:04:04 +0100), Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> says:
> 
> > On Thu, 2003-11-27 at 11:59, David S. Miller wrote:
> > 
> > > I agree, using sizeof() is the less error prone way of
> > > doing things like this.
> > > 
> > > Felipe could you please rewrite your patch like this?
> > 
> > Done!
> 
> Thanks. Ok to me.

I'm slightly cautious here, although I haven't read the patch yet.
Did anyone consider whether any of these structures were copied to
user space, and whether, as a result of this change, we're now
copying uninitialised data to users?

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
