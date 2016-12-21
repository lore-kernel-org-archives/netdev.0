From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [kernel-hardening] Re: HalfSipHash Acceptable Usage
Date: Wed, 21 Dec 2016 23:29:12 +0100
Message-ID: <CAHmME9pww5Q0Wy9MtkO7PAx2Tstfp=6Og3qZLZ=Rh8NaFo0Gog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: kernel-hardening@lists.openwall.com,
        "Theodore Ts'o" <tytso@mit.edu>,
        George Spelvin <linux@sciencehorizons.net>,
        Eric Dumazet <eric.dumazet@gmail.com>, Jason <Jason@zx2c4.com>,
        Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 11:27 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> And "with enough registers" includes ARM and MIPS, right?  So the only
> real problem is 32-bit x86, and you're right, at that point, only
> people who might care are people who are using a space-radiation
> hardened 386 --- and they're not likely to be doing high throughput
> TCP connections.  :-)

Plus the benchmark was bogus anyway, and when I built a more specific
harness -- actually comparing the TCP sequence number functions --
SipHash was faster than MD5, even on register starved x86. So I think
we're fine and this chapter of the discussion can come to a close, in
order to move on to more interesting things.
