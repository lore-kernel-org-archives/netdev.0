From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v8 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to
 prevent overflow
Date: Wed, 17 May 2017 00:11:03 +0200
Message-ID: <CAHmME9o2+HAXSLPURLaPDSSTwMJtQ1ZD+4tCNHUowsnWcxOYsg@mail.gmail.com>
References: <20170511194134.31183-1-Jason@zx2c4.com> <20170511194134.31183-2-Jason@zx2c4.com>
 <30551.1494853968@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        kernel-hardening@lists.openwall.com,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Sabrina Dubroca <sd@queasysnail.net>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <30551.1494853968@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2017 at 3:12 PM, David Howells <dhowells@redhat.com> wrote:
> Is there a reason you moved skb_to_sgvec() in the file rather than just moving
> the comment to it (since you moved the comment anyway)?

1) Because it's easier to understand skb_to_sgvec_nomark as a variant
of skb_to_sgvec, so I'd rather skb_to_sgvec to be first when reading.
2) Because skb_to_sgvec relies on the return value of __skb_to_sgvec,
and so when assessing it, it's sometimes nice to be able to look at
why it will return different things. In that case, it's easier to have
both functions within the same view without scrolling.

It's the little things that make life easier sometimes.
