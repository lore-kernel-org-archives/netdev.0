From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Use ip6_dst_lookup() in ip6_tunnel.c
Date: Thu, 28 Aug 2003 00:09:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030828000940.189f8c98.davem@redhat.com>
References: <Pine.LNX.4.44.0308271403140.7839-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308271403140.7839-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Aug 2003 14:13:31 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> I cleaned up ip6ip6_tnl_xmit() a bit by using ip6_dst_lookup(). As an
> added bonus IPsec processing of the tunneled packets should now be
> possible. Please apply!

This patch doesn't apply cleanly for some reason,
there were some other changes to ip6_tunnel.c lately.

Can you regenerate this against Andrew Mortons 2.6.0-test4--mm2 patch?
Thanks.
