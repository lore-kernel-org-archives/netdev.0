From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 23:18:48 +0100
Message-ID: <CAHmME9oEhmqW3320Ch+Rczu_=CxQyUQXCGLnYjDm-CYbWugnSw@mail.gmail.com>
References: <20161216204358.nlwifgcqnu6pitxs@thunk.org> <20161216221352.26899.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Theodore Ts'o" <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        kernel-hardening@lists.openwall.com,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Vegard Nossum <vegard.nossum@gmail.com>
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161216221352.26899.qmail@ns.sciencehorizons.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2016 at 11:13 PM, George Spelvin
<linux@sciencehorizons.net> wrote:
> Remembering that on "real" machines it's full SipHash, then I'd say that
> 64-bit security + rekeying seems reasonable.

64-bit security for an RNG is not reasonable even with rekeying. No no
no. Considering we already have a massive speed-up here with the
secure version, there's zero reason to start weakening the security
because we're trigger happy with our benchmarks. No no no.
