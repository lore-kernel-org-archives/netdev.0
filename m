From: "David S. Miller" <davem@redhat.com>
Subject: Re: [NAT-T] NON-IKE encapsulation
Date: Thu, 24 Jun 2004 12:46:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040624124654.36b31815.davem@redhat.com>
References: <20040624123603.GA1241@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: agruen@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040624123603.GA1241@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Jun 2004 22:36:03 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I'm having trouble understanding why we need to increase alen by
> two bytes for NON-IKE.  As far as I can see it's adding two bytes
> of random data to the end of the packet.  Is there something
> obvious that I'm missing?

It is intentional as far as I remember.  If it's any other length,
then the other side implementing this non-IKE encap stuff won't
accept the packet, it must be that length.
