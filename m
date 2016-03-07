From: David Howells <dhowells@redhat.com>
Subject: Re: linux-next: manual merge of the crypto tree with the net-next tree
Date: Mon, 07 Mar 2016 11:08:25 +0000
Message-ID: <28626.1457348905@warthog.procyon.org.uk>
References: <20160307131834.70da82d4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20160307131834.70da82d4@canb.auug.org.au>
Content-ID: <28625.1457348905.1@warthog.procyon.org.uk>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Today's linux-next merge of the crypto tree got a conflict in:
> 
>   net/rxrpc/rxkad.c
> 
> between commit:
> 
>   0d12f8a4027d ("rxrpc: Keep the skb private record of the Rx header in host byte order")
> 
> from the net-next tree and commit:
> 
>   1afe593b4239 ("rxrpc: Use skcipher")
> 
> from the crypto tree.

What's the best way to deal with this?  Should I take Herbert's

	[PATCH 18/26] rxrpc: Use skcipher

patch into my rxrpc tree also and pass it on to Dave?

David
