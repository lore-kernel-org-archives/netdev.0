From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV6] Fix dst leak in ipv6_add_addr
Date: Tue, 9 Nov 2004 21:35:09 -0800
Message-ID: <20041109213509.38135698.davem@davemloft.net>
References: <20041106044121.GA16397@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041106044121.GA16397@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 6 Nov 2004 15:41:21 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Found another error-path dst leak.  If the idev->dead check is
> triggered in ipv6_add_addr the rt entry will leak.

Good catch, patch applied.

Thanks Herbert.
