From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: Fri, 23 Jul 2004 09:21:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040723092111.44b289a9@dell_ss3.pdx.osdl.net>
References: <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
	<20040722.200426.99255296.yoshfuji@linux-ipv6.org>
	<1090593676.1128.25.camel@jzny.localdomain>
	<20040723.110007.27520072.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: hadi@znyx.com, davem@redhat.com, arekm@pld-linux.org, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?ISO-8859-1?B?X19fX19fX19fX19f?=
 <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040723.110007.27520072.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 23 Jul 2004 11:00:07 -0400 (EDT)
YOSHIFUJI Hideaki / ____________ <yoshfuji@linux-ipv6.org> wrote:

> In article <1090593676.1128.25.camel@jzny.localdomain> (at 23 Jul 2004 10:41:16 -0400), Jamal Hadi Salim <hadi@znyx.com> says:
> 
> > > Solutions are, for example,
> > >  to allocate new TCA_U32_xxx for rcnt and rhit,
> > > or, 
> > >  to rename TCA_U32_SEL to TCA_U32_OLS_SEL and allocate new value for 
> > >  TCA_U32_SEL.
> > 
> > 
> > we could do this, but since we are already fscking the ABI it is not
> > valuable.
> 
> BTW, what's for rcnt etc.? I don't see the point. 
> 
> They're not (effectively) used in kernel.
> I'd suggest to remove these things and to maintain the original ABI.
> 
> If rcnt etc. are for other purposes, such as statistics for userspace,
> please allocate another structure / interface for it.
> 
> (And... cheking size is too strict;
> we need to relax it to accept old binaries if we add something
> at the tail of structure.)

Looking at the netlink style, wouldn't it make sense to add additional
separate payloads for the new features.  This keeps the API the same and
the kernel can easily adapt for new/old values.
