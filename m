From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH] Add nl_open to libnetlink
Date: Mon, 5 Jul 2004 16:05:00 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705160500.208591b5@localhost>
References: <20040703094632.GA14235@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
        Stephen Hemminger
 <shemminger@osdl.org>, netdev@oss.sgi.com
In-Reply-To: <20040703094632.GA14235@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

On Sat, 3 Jul 2004 19:46:32 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I'm in the process of writing two new modules fo ip(8), ippolicy and
> ipstate which will be a NETLINK based replacement for setkey.
> 
> In order to do so, I need to get libnetlink to speak the XFRM protocol.
> Thus I've added a new nl_open function which allows the protocol to
> be specified.

I agree with it.

Anyway, I have code for ip(8) for similar reason.
The patch is below:
http://www.linux-ipv6.org/~nakam/ipxfrm-20040705.diff

Can you take a look at it, Stephen and Herbert?

I'm in the process of writing Mobile IPv6 with extended xfrm,
so I'm interested in extending "ip(8) which can handle xfrm".

About "nl_open", my code is not the same for Herbert's one actually, but
similar change is in it (and Herberts' one is also welcome for me).

My patch is:

- Checking SA's algorithm is not implemented yet
- Command line option is `ip xfrm policy` and `ip xfrm state`.
- defined "USE_MIP6" for Mobile IPv6.
	(please ignore MIPv6 now...)

# I can prepare cleaner patch (e.g. removing Mobile IPV6 part), if you want.

Regards,

-- 
Masahide NAKAMURA
