From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPsec and Path MTU
Date: Wed, 16 Jun 2004 13:49:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616134904.49b462ce.davem@redhat.com>
References: <20040615124334.GA25164@gondor.apana.org.au>
	<20040616121026.GA1169@gondor.apana.org.au>
	<20040616202341.GD29781@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20040616202341.GD29781@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Jun 2004 00:23:41 +0400
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> Actually, the last time when we discussed this we had only one
> but _damn_ ugly problem. We have to remember original packet content
> to reply with ICMP correctly, when encapsulating. Is it possible
> that you are confused with this? We do send invalid ICMP_FRAG_NEEDED
> from ip_fragment. PMTU discovery will work only if we reply to original,
> not transofrmed packet. See?

Yes, it seems we should finally implement this beast.
