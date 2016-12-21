From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: HalfSipHash Acceptable Usage
Date: Wed, 21 Dec 2016 19:40:12 +0100
Message-ID: <CAHmME9rbdJKdQ8bfwRgYWbpjHaPX-+zKG9=EP+tW7CnRkQBSWA@mail.gmail.com>
References: <1482335804.8944.44.camel@edumazet-glaptop3.roam.corp.google.com> <20161221183751.1123.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Andi Kleen <ak@linux.intel.com>,
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
        "Theodore Ts'o" <tytso@mit.edu>,
        Vegard Nossum <vegard.nossum@gmail.com>
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161221183751.1123.qmail@ns.sciencehorizons.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 7:37 PM, George Spelvin
<linux@sciencehorizons.net> wrote:
> SipHash annihilates the competition on 64-bit superscalar hardware.
> SipHash dominates the field on 64-bit in-order hardware.
> SipHash wins easily on 32-bit hardware *with enough registers*.
> On register-starved 32-bit machines, it really struggles.
>
> As I explained, in that last case, SipHash barely wins at all.
> (On a P4, it actually *loses* to MD5, not that anyone cares.  Running
> on a P4 and caring about performance are mutually exclusive.)

>From the discussion off list which examined your benchmark code, it
looks like we're going to move ahead with SipHash.
