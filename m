From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Add nl_open to libnetlink
Date: Wed, 7 Jul 2004 11:08:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707110820.5ac56fa5@dell_ss3.pdx.osdl.net>
References: <20040703094632.GA14235@gondor.apana.org.au>
	<20040705160500.208591b5@localhost>
	<20040706140550.2d483dc8@dell_ss3.pdx.osdl.net>
	<20040707130950.0112edf6@localhost>
	<20040707140533.41c66c03@localhost>
	<20040707155602.4698121a@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <20040707155602.4698121a@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 7 Jul 2004 15:56:02 +0900
Masahide NAKAMURA <nakam@linux-ipv6.org> wrote:

> Hello Stephen and Herbert,
> 
> > > > On Sat, 3 Jul 2004 19:46:32 +1000
> > > > Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > > > 
> > > > > I'm in the process of writing two new modules fo ip(8), ippolicy and
> > > > > ipstate which will be a NETLINK based replacement for setkey.
> > > > > 
> > > > > In order to do so, I need to get libnetlink to speak the XFRM protocol.
> > > > > Thus I've added a new nl_open function which allows the protocol to
> > > > > be specified.
> > > > 
> > > > I agree with it.
> > > > 
> > > > Anyway, I have code for ip(8) for similar reason.
> 
> I've updated the patch and it can build with 2.6.7 kernel headers.
> Can you check it?
> 
> http://www.linux-ipv6.org/~nakam/ipxfrm-20040707_2.diff
> 

Got it, it builds and is in the current bk tree; will go out with next snapshot
this week.
