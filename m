From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [kernel-hardening] Re: [PATCH v7 3/6] random: use SipHash in
 place of MD5
Date: Thu, 22 Dec 2016 16:53:20 +0100
Message-ID: <CAHmME9or5jdJUCAyY3-L1Wto6LGG9XDvMyhuxiTgTpVgQdWtjw@mail.gmail.com>
References: <20161216030328.11602-1-Jason@zx2c4.com> <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com> <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
 <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
 <20161222054125.lzxhd6ctovm3wk4p@thunk.org> <1482410840.2472.2.camel@stressinduktion.org>
 <CAHmME9r_zTHo=dxRRK6UrjJ_dKV14yYsZsxCc362z4CPoVkddw@mail.gmail.com>
 <5c306c80-3499-8b92-21d0-c197f30ce326@stressinduktion.org>
 <CAHmME9qZviooxOW+e=khazG0phSEWwZyKj=eayre_7hs8d+cQw@mail.gmail.com>
 <CAHmME9pu-2CY2WRHevnpwo-9qnZcTpqQgC2voGFOpSjo+LPiUA@mail.gmail.com>
 <1482420815.2673.1.camel@stressinduktion.org> <CAHmME9ok8iWfZybyDki13v6Xf3usRet1y8oUcDcy+5YwkARQPA@mail.gmail.com>
 <1482421900.2673.3.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kernel-hardening@lists.openwall.com,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>,
        Eric Dumazet <edumazet@google.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Andi Kleen <ak@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482421900.2673.3.camel@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 4:51 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> This algorithm should be a non-seeded algorithm, because the hashes
> should be stable and verifiable by user space tooling. Thus this would
> need a hashing algorithm that is hardened against pre-image
> attacks/collision resistance, which siphash is not. I would prefer some
> higher order SHA algorithm for that actually.

Right. SHA-256, SHA-512/256, Blake2s, or Blake2b would probably be
good candidates for this.
