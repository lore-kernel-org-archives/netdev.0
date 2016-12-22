From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: BPF hash algo (Re: [kernel-hardening] Re: [PATCH v7 3/6] random:
 use SipHash in place of MD5)
Date: Thu, 22 Dec 2016 21:02:29 +0100
Message-ID: <c82ea5a2-3139-5f12-e5f7-df2e1a6d9c24@stressinduktion.org>
References: <CALCETrUATPeaCJTQZN2h=ct6HH-xLt4V8T0PfPHNFGFN2HWtTA@mail.gmail.com>
 <1482425969.2673.5.camel@stressinduktion.org>
 <CALCETrW_T1v4qKPJDs5dXwAnAit3M52AWMH-K+GJLb1WoLMuRQ@mail.gmail.com>
 <CAADnVQ+memUT2zcc-wunP0QgWSLWpmnSJNRJZmfDdc+FBb=gEg@mail.gmail.com>
 <CALCETrUWw2m8k3b8ibOeN-7o9b+8MrnX4btUWqS188WSsLzDjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
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
To: Andy Lutomirski <luto@kernel.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:37365 "EHLO
        out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S966325AbcLVUCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 15:02:36 -0500
In-Reply-To: <CALCETrUWw2m8k3b8ibOeN-7o9b+8MrnX4btUWqS188WSsLzDjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.12.2016 20:56, Andy Lutomirski wrote:
> It's also not quite clear to me why userspace needs to be able to
> calculate the digest on its own.  A bpf(BPF_CALC_PROGRAM_DIGEST)
> command that takes a BPF program as input and hashes it would seem to
> serve the same purpose, and that would allow the kernel to key the
> digest and change the algorithm down the road without breaking things.

I think that people expect digests of BPF programs to be stable over
time and reboots.
