From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH v8 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to prevent overflow
Date: Mon, 15 May 2017 14:12:48 +0100
Message-ID: <30551.1494853968@warthog.procyon.org.uk>
References: <20170511194134.31183-2-Jason@zx2c4.com> <20170511194134.31183-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        kernel-hardening@lists.openwall.com,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Sabrina Dubroca <sd@queasysnail.net>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170511194134.31183-2-Jason@zx2c4.com>
Content-ID: <30550.1494853968.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason A. Donenfeld <Jason@zx2c4.com> wrote:

> +int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
> ...
> -int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)

Is there a reason you moved skb_to_sgvec() in the file rather than just moving
the comment to it (since you moved the comment anyway)?

David
