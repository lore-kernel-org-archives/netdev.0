From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Re: [PATCH v7 3/6] random: use SipHash in
 place of MD5
Date: Thu, 22 Dec 2016 10:58:53 -0500
Message-ID: <20161222155853.beqowf2qfg7igf23@thunk.org>
References: <20161216030328.11602-1-Jason@zx2c4.com>
 <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com>
 <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
 <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
 <20161222054125.lzxhd6ctovm3wk4p@thunk.org>
 <CAHmME9o=yLOLr2w3xYj2up-UW0tXtv=0A5ffiTiVCCHkv6Twxg@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-hardening@lists.openwall.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>,
	Tom Herbert <tom@herbertland.com>, Andi Kleen <ak@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <kernel-hardening-return-5786-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <CAHmME9o=yLOLr2w3xYj2up-UW0tXtv=0A5ffiTiVCCHkv6Twxg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 07:03:29AM +0100, Jason A. Donenfeld wrote:
> I find this compelling. We'll have one csprng for both
> get_random_int/long and for /dev/urandom, and we'll be able to update
> that silly warning on the comment of get_random_int/long to read
> "gives output of either rdrand quality or of /dev/urandom quality",
> which makes it more useful for other things. It introduces less error
> prone code, and it lets the RNG analysis be spent on just one RNG, not
> two.
> 
> So, with your blessing, I'm going to move ahead with implementing a
> pretty version of this for v8.

Can we do this as a separate series, please?  At this point, it's a
completely separate change from a logical perspective, and we can take
in the change through the random.git tree.

Changes that touch files that are normally changed in several
different git trees leads to the potential for merge conflicts during
the linux-next integration and merge window processes.  Which is why
it's generally best to try to isolate changes as much as possible.

Cheers,

						- Ted
