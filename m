From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] Vegas and tcp parameters per route
Date: Mon, 15 Mar 2004 09:20:18 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040315092018.1e843d83@dell_ss3.pdx.osdl.net>
References: <20040312151729.25d9c696@dell_ss3.pdx.osdl.net>
	<1079160064.11606.15.camel@viivi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Pasi Sarolahti <pasi.sarolahti@iki.fi>
In-Reply-To: <1079160064.11606.15.camel@viivi>
List-Id: netdev.vger.kernel.org

On Sat, 13 Mar 2004 08:41:05 +0200
Pasi Sarolahti <pasi.sarolahti@iki.fi> wrote:

> Hi Stephen,
> 
> On Sat, 2004-03-13 at 01:17, Stephen Hemminger wrote:
> > This is the second more complete version of TCP Vegas that allows setting
> > the options based on route.  Reused the RTAX_FEATURE metric which got
> > defined but never used, to provide the ability to select vegas, westwood,
> > and/or frto per route.
> > 
> > There is an modified version of iproute2 available at
> > 	http://developer.osdl.org/shemminger/tcp/iproute2-exp.tar.bz2
> > With this it is possible to setup options per route with ip.
> > 	ip route add to 10.0.0.1 features vegas/frto
> 
> I would still like to keep the good old sysctl interface (well, at least
> for tcp_frto), because I'd belive it is more familiar and easier to use
> for many and not dependent of external tools.
> 
> Would it be too complicated, if sysctl would give the global default,
> from which one can deviate using RTAX_FEATURE?

Maybe for frto it needs to stay, but sysctl's are more painful and complex
than keeping the stuff in the routing info.  Also, the external tools are
part of every distro, except for a few embedded systems, the networking code
depends on user tools already.
