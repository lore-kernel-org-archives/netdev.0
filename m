From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Fri, 28 Nov 2003 04:54:13 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031128.045413.133305490.yoshfuji@linux-ipv6.org>
References: <1069934643.2393.0.camel@teapot.felipe-alfaro.com>
	<20031127.210953.116254624.yoshfuji@linux-ipv6.org>
	<20031127194602.A25015@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felipe_alfaro@linuxmail.org, davem@redhat.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: rmk+lkml@arm.linux.org.uk
In-Reply-To: <20031127194602.A25015@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031127194602.A25015@flint.arm.linux.org.uk> (at Thu, 27 Nov 2003 19:46:02 +0000), Russell King <rmk+lkml@arm.linux.org.uk> says:

> > > > I agree, using sizeof() is the less error prone way of
> > > > doing things like this.
> > > > 
> > > > Felipe could you please rewrite your patch like this?
> > > 
> > > Done!
> > 
> > Thanks. Ok to me.
> 
> I'm slightly cautious here, although I haven't read the patch yet.
> Did anyone consider whether any of these structures were copied to
> user space, and whether, as a result of this change, we're now
> copying uninitialised data to users?

I believe that it, to change from strcpy() to strlcpy(), just 
eliminates possibility of buffer-overrun.

--yoshfuji
