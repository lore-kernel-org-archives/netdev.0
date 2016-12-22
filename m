From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Re: [PATCH v7 3/6] random: use SipHash in
 place of MD5
Date: Thu, 22 Dec 2016 19:13:39 +0100
Message-ID: <CAHmME9q_NkVVCG8hYw_NMjTLsBUoEq334i+jG+yvXOKR+wY6Xw@mail.gmail.com>
References: <20161216030328.11602-1-Jason@zx2c4.com> <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com> <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
 <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
 <20161222054125.lzxhd6ctovm3wk4p@thunk.org> <1482410840.2472.2.camel@stressinduktion.org>
 <CAHmME9r_zTHo=dxRRK6UrjJ_dKV14yYsZsxCc362z4CPoVkddw@mail.gmail.com>
 <20161222155447.u3ayvw4gmorhswjv@thunk.org> <32db19ab-0c19-628c-3475-2ccb8050563a@stressinduktion.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Theodore Ts'o" <tytso@mit.edu>, kernel-hardening@lists.openwall.com,
	Andy Lutomirski <luto@amacapital.net>, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, David Laight <David.Laight@aculab.com>,
	Eric Dumazet <edumazet@google.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>, Tom Herbert <tom@herbertland.com>,
	Andi Kleen <ak@linux.intel.com>, "David S. Miller" <davem@davemloft.net>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <kernel-hardening-return-5800-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <32db19ab-0c19-628c-3475-2ccb8050563a@stressinduktion.org>
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 7:08 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> I wasn't concerned about performance but more about DoS resilience. I
> wonder how safe half md4 actually is in terms of allowing users to
> generate long hash chains in the filesystem (in terms of length
> extension attacks against half_md4).

AFAIK, this is a real vulnerability that needs to be addressed.

Judging by Ted's inquiry about my siphash testing suite, I assume he's
probably tinkering around with it as we speak. :)


Meanwhile I've separated things into several trees:

1. chacha20 rng, already submitted:
https://git.zx2c4.com/linux-dev/log/?h=random-next

2. md5 cleanup, not yet submitted:
https://git.zx2c4.com/linux-dev/log/?h=md5-cleanup

3. md4 cleanup, already submitted:
https://git.zx2c4.com/linux-dev/log/?h=ext4-next-md4-cleanup

4. siphash and networking, not yet submitted as a x/4 series:
https://git.zx2c4.com/linux-dev/log/?h=net-next-siphash

I'll submit (4) in a couple of days, waiting for any comments on the
existing patch-set.

Jason
