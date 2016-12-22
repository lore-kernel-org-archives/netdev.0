From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: BPF hash algo (Re: [kernel-hardening] Re: [PATCH v7 3/6] random:
 use SipHash in place of MD5)
Date: Thu, 22 Dec 2016 11:34:36 -0800
Message-ID: <CAADnVQ+memUT2zcc-wunP0QgWSLWpmnSJNRJZmfDdc+FBb=gEg@mail.gmail.com>
References: <CALCETrUATPeaCJTQZN2h=ct6HH-xLt4V8T0PfPHNFGFN2HWtTA@mail.gmail.com>
 <1482425969.2673.5.camel@stressinduktion.org> <CALCETrW_T1v4qKPJDs5dXwAnAit3M52AWMH-K+GJLb1WoLMuRQ@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>, Daniel Borkmann <daniel@iogearbox.net>,
	"Jason A. Donenfeld" <Jason@zx2c4.com>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Theodore Ts'o" <tytso@mit.edu>,
	Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, David Laight <David.Laight@aculab.com>,
	Eric Dumazet <edumazet@google.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>, Tom Herbert <tom@herbertland.com>,
	Andi Kleen <ak@linux.intel.com>, "David S. Miller" <davem@davemloft.net>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-5804-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrW_T1v4qKPJDs5dXwAnAit3M52AWMH-K+GJLb1WoLMuRQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 9:25 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Thu, Dec 22, 2016 at 8:59 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On Thu, 2016-12-22 at 08:07 -0800, Andy Lutomirski wrote:
>>
>> We don't prevent ebpf programs being loaded based on the digest but
>> just to uniquely identify loaded programs from user space and match up
>> with their source.
>
> The commit log talks about using the hash to see if the program has
> already been compiled and JITted.  If that's done, then a collision
> will directly cause the kernel to malfunction.

Andy, please read the code.
we could have used jhash there just as well.
Collisions are fine.
