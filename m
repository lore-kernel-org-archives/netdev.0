From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH] Add nl_open to libnetlink
Date: Wed, 7 Jul 2004 13:09:50 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707130950.0112edf6@localhost>
References: <20040703094632.GA14235@gondor.apana.org.au>
	<20040705160500.208591b5@localhost>
	<20040706140550.2d483dc8@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040706140550.2d483dc8@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 14:05:50 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> On Mon, 5 Jul 2004 16:05:00 +0900
> Masahide NAKAMURA <nakam@linux-ipv6.org> wrote:
> 
> > Hello,
> > 
> > On Sat, 3 Jul 2004 19:46:32 +1000
> > Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > 
> > > I'm in the process of writing two new modules fo ip(8), ippolicy and
> > > ipstate which will be a NETLINK based replacement for setkey.
> > > 
> > > In order to do so, I need to get libnetlink to speak the XFRM protocol.
> > > Thus I've added a new nl_open function which allows the protocol to
> > > be specified.
> > 
> > I agree with it.
> > 
> > Anyway, I have code for ip(8) for similar reason.
> > The patch is below:
> > http://www.linux-ipv6.org/~nakam/ipxfrm-20040705.diff
> 
> This code won't build with current kernel headers. There is no xfrmsel_icmp_type
> in current 2.6 definition of struct xfrm_selector.

I've made another patch which can build with 2.6.7 kernel headers.
(And I removed some unnecessary code for the kernel.)

Try below:
http://www.linux-ipv6.org/~nakam/ipxfrm-20040707.diff


BTW, The definition in previous patch is for understanding ICMP
type/code by xfrm_selector. I wrote the kernel feature and I'm
testing it. Anyway, I'll send it to the list, too.

Thanks,

-- 
Masahide NAKAMURA
