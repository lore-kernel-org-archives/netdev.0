From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Iproute2: update
Date: Mon, 17 Jan 2005 23:24:37 +0100
Message-ID: <20050117222437.GI26856@postel.suug.ch>
References: <20050112125903.64d42737@dxpl.pdx.osdl.net> <1105895352.1091.705.camel@jzny.localdomain> <1105897532.1097.749.camel@jzny.localdomain> <20050117202022.GG26856@postel.suug.ch> <20050117205734.GH26856@postel.suug.ch> <1105997946.1078.308.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105997946.1078.308.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1105997946.1078.308.camel@jzny.localdomain> 2005-01-17 16:39
> On Mon, 2005-01-17 at 15:57, Thomas Graf wrote:
> > > I'll put this changes into my tree given you're fine with it and stephen
> > > can pull them. As I said, the ipt code is still missing, I can merge
> > > them into my tree as well if you want.
> > 
> > Stephen: you can pull jamal's changes with my modifications from
> > bk://tgr.bkbits.net/iproute2-tgr if you like.
> 
> Thomas,
> 
> Look at iproute2-2.6.10-ss050112 - ipt is in there and thats where my
> patches are against.
> 
> ----
> [hadi@jzny hadi]$ find iproute2-2.6.10-ss050112 | grep ipt
> iproute2-2.6.10-ss050112/examples/dhcp-client-script
> iproute2-2.6.10-ss050112/tc/m_ipt.c
> iproute2-2.6.10-ss050112/ip/iptunnel.c
> iproute2-2.6.10-ss050112/include/iptables.h
> iproute2-2.6.10-ss050112/include/libiptc
> iproute2-2.6.10-ss050112/include/libiptc/ipt_kernel_headers.h
> iproute2-2.6.10-ss050112/include/libiptc/libip6tc.h
> iproute2-2.6.10-ss050112/include/libiptc/libiptc.h
> iproute2-2.6.10-ss050112/include/iptables_common.h
> iproute2-2.6.10-ss050112/include/linux/tc_act/tc_ipt.h
> -----------

Ah, great. I didn't look at the release and they're not in the
bk tree. Maybe stephen forgot to push his changes.

> So the IPT thing is unneeded. Also note that i had it the way you
> have it in configure but Stephen didnt like it.

OK. I don't care, it's really ugly to compile iproute2 without
iptables sources though.

> In regards to pedit - wait until the code goes in then shoot at it.
> Theres plenty of things for you to shoot at ;-> i think last time i
> really looked at it was ~2 years ago.

I'll keep those changes and eventually merge them sometimes. It's not
that important.
