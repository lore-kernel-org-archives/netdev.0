From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: (5/5) Allow IPv6 tunnels without own IPv6 address
Date: Mon, 1 Sep 2003 13:48:44 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309011345141.17318-100000@netcore.fi>
References: <20030901020340.5a128836.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ville Nuorvala <vnuorval@tcs.hut.fi>, <yoshfuji@linux-ipv6.org>,
   <usagi-core@linux-ipv6.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030901020340.5a128836.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Sep 2003, David S. Miller wrote:
> On Mon, 1 Sep 2003 11:18:30 +0300 (EEST)
> Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:
> 
> > Unfortunately the IPv6 tunneling spec (RFC2473) is broken on this point :(
> > I should probably raise this issue on the IETF ipv6 WG mailing list.
>  ...
> > The first problem is, that the way to generate the interface-identifier
> > isn't currently specified in the tunnel spec.
>  ...
> > The second problem is, that this method alone doesn't yet guarantee
> > unique identifiers to the two tunnel endpoints.
> 
> This is exactly what I was thinking.  I really don't think link-
> local addresses make any sense on a software device such as the
> ipip6 tunnels.

Well, link-local addresses are used e.g. by routing protocols and such, so 
having one is probably rather important..

FWIW, on FreeBSD platform they take the link-local address of the first
physical interface, and give the exact same link-local address on all of
the tunnels, disambiuating them with the scope identifier.  Seems like an
OK appaorach too, and guarantees (to the degree of unique MAC addresses)  
that the addresses of the endpoints do not clash.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
