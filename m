From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: (5/5) Allow IPv6 tunnels without own IPv6 address
Date: Mon, 1 Sep 2003 02:03:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901020340.5a128836.davem@redhat.com>
References: <20030901.112409.61391981.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0309010931420.27694-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0309010931420.27694-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Sep 2003 11:18:30 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> Unfortunately the IPv6 tunneling spec (RFC2473) is broken on this point :(
> I should probably raise this issue on the IETF ipv6 WG mailing list.
 ...
> The first problem is, that the way to generate the interface-identifier
> isn't currently specified in the tunnel spec.
 ...
> The second problem is, that this method alone doesn't yet guarantee
> unique identifiers to the two tunnel endpoints.

This is exactly what I was thinking.  I really don't think link-
local addresses make any sense on a software device such as the
ipip6 tunnels.
