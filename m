From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 11:47:35 -0800
Message-ID: <CALx6S351VFRZmEQphRQy6YtmZYPnOtTN7=XiNrJmhWJGv4HUBg@mail.gmail.com>
References: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
 <20161216034618.28276.qmail@ns.sciencehorizons.net> <CAGiyFdd6_LVzUUfFcaqMyub1c2WPvWUzAQDCH+Aza-_t6mvmXg@mail.gmail.com>
 <CAHmME9pjoAsoct1sVDpFFuqaqutv9X7DGJ5OBQXRAS57KFimUA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
	George Spelvin <linux@sciencehorizons.net>, Andi Kleen <ak@linux.intel.com>,
	David Miller <davem@davemloft.net>, David Laight <David.Laight@aculab.com>,
	Eric Biggers <ebiggers3@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	kernel-hardening@lists.openwall.com,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Andy Lutomirski <luto@amacapital.net>, Netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>, "Theodore Ts'o" <tytso@mit.edu>, vegard.nossum@gmail.com,
	"Daniel J . Bernstein" <djb@cr.yp.to>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <kernel-hardening-return-5647-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAHmME9pjoAsoct1sVDpFFuqaqutv9X7DGJ5OBQXRAS57KFimUA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2016 at 4:39 AM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> Hey JP,
>
> On Fri, Dec 16, 2016 at 9:08 AM, Jean-Philippe Aumasson
> <jeanphilippe.aumasson@gmail.com> wrote:
>> Here's a tentative HalfSipHash:
>> https://github.com/veorq/SipHash/blob/halfsiphash/halfsiphash.c
>>
>> Haven't computed the cycle count nor measured its speed.
>
Tested this. Distribution and avalanche effect are still good. Speed
wise I see about a 33% improvement over siphash (20 nsecs/op versus 32
nsecs). That's about 3x of jhash speed (7 nsecs). So that might closer
to a more palatable replacement for jhash. Do we lose any security
advantages with halfsiphash?

Tom

> This is incredible. Really. Wow!
>
> I'll integrate this into my patchset and will write up some
> documentation about when one should be used over the other.
>
> Thanks again. Quite exciting.
>
> Jason
