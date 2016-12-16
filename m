From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 21:39:54 +0100
Message-ID: <CAHmME9oWDHs2DCRFc8WmvScrj0-cz9EKUHFeiRNTanXLe-v2Sw@mail.gmail.com>
References: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
 <20161216034618.28276.qmail@ns.sciencehorizons.net> <CAGiyFdd6_LVzUUfFcaqMyub1c2WPvWUzAQDCH+Aza-_t6mvmXg@mail.gmail.com>
 <CAHmME9pjoAsoct1sVDpFFuqaqutv9X7DGJ5OBQXRAS57KFimUA@mail.gmail.com> <CAGiyFddB_HT3H2yhYQ5rprYZ487rJ4iCaH9uPJQD57hiPbn9ng@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: George Spelvin <linux@sciencehorizons.net>, Andi Kleen <ak@linux.intel.com>,
	David Miller <davem@davemloft.net>, David Laight <David.Laight@aculab.com>,
	Eric Biggers <ebiggers3@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	kernel-hardening@lists.openwall.com,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Andy Lutomirski <luto@amacapital.net>, Netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	"Theodore Ts'o" <tytso@mit.edu>, Vegard Nossum <vegard.nossum@gmail.com>,
	"Daniel J . Bernstein" <djb@cr.yp.to>
To: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Return-path: <kernel-hardening-return-5652-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGiyFddB_HT3H2yhYQ5rprYZ487rJ4iCaH9uPJQD57hiPbn9ng@mail.gmail.com>
List-Id: netdev.vger.kernel.org

Hi JP,

On Fri, Dec 16, 2016 at 2:22 PM, Jean-Philippe Aumasson
<jeanphilippe.aumasson@gmail.com> wrote:
> It needs some basic security review, which I'll try do next week (check for
> security margin, optimality of rotation counts, etc.). But after a lot of
> experience with this kind of construction (BLAKE, SipHash, NORX), I'm
> confident it will be safe as it is.

I've implemented it in my siphash kernel branch:

https://git.zx2c4.com/linux-dev/log/?h=siphash

It's the commit that has "HalfSipHash" in the log message. As the
structure is nearly identical to SipHash, there wasn't a lot to
change, and so the same implementation strategy exists for each.

When you've finished your security review and feel good about it, some
test vectors using the same formula (key={0x03020100, 07060504},
input={0x0, 0x1, 0x2, 0x3...}, output=test_vectors) would be nice for
verification.

Jason
