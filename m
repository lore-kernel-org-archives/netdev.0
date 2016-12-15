From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v3 1/3] siphash: add cryptographically secure hashtable function
Date: Wed, 14 Dec 2016 16:10:57 -0800
Message-ID: <CA+55aFw4QLuwkxq4VzLMPTJTec-hOu1Fi8e076TNnW0Yq9yp8A@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <20161214184605.24006-1-Jason@zx2c4.com>
 <CALx6S35UgTyqkYUjS5gYFH4HnjW974WQ_JiDXxgb9rZ7gnY52Q@mail.gmail.com>
 <CAHmME9oMaQOhzJbNKh8GN759iJngeRdXt3naOnFhY9mD6t5Kxg@mail.gmail.com>
 <CAHmME9pR3tD2zknKsYaFaTJm_3aBBOA6c174hypm6S-q9wp5nw@mail.gmail.com>
 <CALx6S35VBjw42G6rHPrNfVaBfLMz3YZVjs3D3hBG=4gp5+g5tA@mail.gmail.com>
 <CAHmME9rpvf4tyDjZcJAJxMAW1LcqNm7DiquiYX0uQhRzDLbwqw@mail.gmail.com>
 <CA+55aFyBGQpEKiAcs0w58ZEie+L8OrWvf_2hvGx4E=L56p5hMg@mail.gmail.com> <CAHmME9pu6No0wqPzPpaBwQR_b+5CXvh0kke7J8ouN=rx4pxMGg@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>, Netdev <netdev@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>, "Daniel J . Bernstein" <djb@cr.yp.to>,
	Eric Biggers <ebiggers3@gmail.com>, David Laight <David.Laight@aculab.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <kernel-hardening-return-5564-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Sender: linus971@gmail.com
In-Reply-To: <CAHmME9pu6No0wqPzPpaBwQR_b+5CXvh0kke7J8ouN=rx4pxMGg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Wed, Dec 14, 2016 at 3:34 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>
> Or does your reasonable dislike of "word" still allow for the use of
> dword and qword, so that the current function names of:

dword really is confusing to people.

If you have a MIPS background, it means 64 bits. While to people with
Windows programming backgrounds it means 32 bits.

Please try to avoid using it.

As mentioned, I think almost everybody agrees on the "q" part being 64
bits, but that may just be me not having seen it in any other context.

And before anybody points it out - yes, we already have lots of uses
of "dword" in various places. But they tend to be mostly
hardware-specific - either architectures or drivers.

So I'd _prefer_ to try to keep "word" and "dword" away from generic
helper routines. But it's not like anything is really black and white.

           Linus
