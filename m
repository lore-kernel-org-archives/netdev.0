From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: BPF hash algo (Re: [kernel-hardening] Re: [PATCH v7 3/6] random:
 use SipHash in place of MD5)
Date: Fri, 23 Dec 2016 11:23:43 +0100
Message-ID: <585CFB2F.8010102@iogearbox.net>
References: <CALCETrUATPeaCJTQZN2h=ct6HH-xLt4V8T0PfPHNFGFN2HWtTA@mail.gmail.com> <1482425969.2673.5.camel@stressinduktion.org> <CALCETrW_T1v4qKPJDs5dXwAnAit3M52AWMH-K+GJLb1WoLMuRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Theodore Ts'o <tytso@mit.edu>, Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>,
        Eric Dumazet <edumazet@google.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Andi Kleen <ak@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Andy Lutomirski <luto@amacapital.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrW_T1v4qKPJDs5dXwAnAit3M52AWMH-K+GJLb1WoLMuRQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/22/2016 06:25 PM, Andy Lutomirski wrote:
> On Thu, Dec 22, 2016 at 8:59 AM, Hannes Frederic Sowa
[...]
>> I wondered if bpf program loading should have used the module loading
>> infrastructure from the beginning...
>
> That would be way too complicated and would be nasty for the unprivileged cases.

Also, there are users be it privileged or not that don't require to have a full
obj loader from user space, but are fine with just hard-coding parts or all of
the insns in their application. Back then we settled with using fds based on
Andy's suggestion, it has both ups and downs as we saw along the way but worked
okay thus far.
