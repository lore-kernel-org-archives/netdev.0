From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Call xfrm6_rcv in xfrm6_tunnel_rcv
Date: Wed, 18 Aug 2004 15:03:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040818150334.0ff3462d.davem@redhat.com>
References: <20040817122638.GA1855@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040817122638.GA1855@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Aug 2004 22:26:38 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch reuses the code in xfrm6_input.c for receiving xfrm6_tunnel
> packets.  This removes duplicate code as well as fixing the bugs unique
> to xfrm6_tunnel_input.  For example, it didn't move the MAC header down.
> Nor did it do anything with ECN.

Looks great, patch applied.
