From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: BPF hash algo (Re: [kernel-hardening] Re: [PATCH v7 3/6] random:
 use SipHash in place of MD5)
Date: Fri, 23 Dec 2016 22:18:18 +0100
Message-ID: <CAHmME9rq2oBPZW0+0HRO6kqFRP899BfhY5xig4j1yTF02rA81w@mail.gmail.com>
References: <CALCETrUATPeaCJTQZN2h=ct6HH-xLt4V8T0PfPHNFGFN2HWtTA@mail.gmail.com>
 <1482425969.2673.5.camel@stressinduktion.org> <585CF6A3.1050107@iogearbox.net>
 <1482490762.3353.2.camel@stressinduktion.org> <585D11BF.60903@iogearbox.net>
 <CALCETrVgnnbstPoPf-0bZ_ySDydXNCp5dLAEvhAD9cApozFsng@mail.gmail.com>
 <CALCETrXHoPBV1UpLwtLjjmqJXVpgEUTCnwePDLx4g6a1SFMZaw@mail.gmail.com> <ec43894a-7b54-ff30-9874-bb4a25314e09@stressinduktion.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Theodore Ts'o" <tytso@mit.edu>,
	Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, David Laight <David.Laight@aculab.com>,
	Eric Dumazet <edumazet@google.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>, Tom Herbert <tom@herbertland.com>,
	Andi Kleen <ak@linux.intel.com>, "David S. Miller" <davem@davemloft.net>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <kernel-hardening-return-5821-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <ec43894a-7b54-ff30-9874-bb4a25314e09@stressinduktion.org>
List-Id: netdev.vger.kernel.org

On Fri, Dec 23, 2016 at 7:19 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Factoring out sha3

Per the other thread, you probably don't actually want SHA3, because
it's slow in software. You want SHA2. If you want something faster and
better, then Blake2 is most certainly the way to go. I'll be
submitting some patches in a month or so adding Blake2 for future use
in the tree.

Jason
