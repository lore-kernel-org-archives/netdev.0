From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: Fri, 23 Jul 2004 11:00:07 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040723.110007.27520072.yoshfuji@linux-ipv6.org>
References: <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
	<20040722.200426.99255296.yoshfuji@linux-ipv6.org>
	<1090593676.1128.25.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, davem@redhat.com, arekm@pld-linux.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@znyx.com
In-Reply-To: <1090593676.1128.25.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <1090593676.1128.25.camel@jzny.localdomain> (at 23 Jul 2004 10:41:16 -0400), Jamal Hadi Salim <hadi@znyx.com> says:

> > Solutions are, for example,
> >  to allocate new TCA_U32_xxx for rcnt and rhit,
> > or, 
> >  to rename TCA_U32_SEL to TCA_U32_OLS_SEL and allocate new value for 
> >  TCA_U32_SEL.
> 
> 
> we could do this, but since we are already fscking the ABI it is not
> valuable.

BTW, what's for rcnt etc.? I don't see the point. 

They're not (effectively) used in kernel.
I'd suggest to remove these things and to maintain the original ABI.

If rcnt etc. are for other purposes, such as statistics for userspace,
please allocate another structure / interface for it.

(And... cheking size is too strict;
we need to relax it to accept old binaries if we add something
at the tail of structure.)

Thanks.

--yoshfuji
