From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [kernel-hardening] Re: [PATCH v2 1/4] siphash: add
 cryptographically secure hashtable function
Date: Thu, 15 Dec 2016 22:11:24 +0100
Message-ID: <CAHmME9p+xEBTKz+Wfy5Ypav4HU7H+rnA-0hLgd1sMmthDzOmvw@mail.gmail.com>
References: <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02401ED@AcuExch.aculab.com>
 <707472e1-b385-836d-c4c6-791c1dcc0776@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02402C0@AcuExch.aculab.com>
 <0f3c3694-c00b-aae2-5b08-25bc64bf6372@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB0240437@AcuExch.aculab.com>
 <f6813084-6f46-0b22-e9c3-97b2e266f8f6@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB0240529@AcuExch.aculab.com>
 <924ef794-eae0-2a6b-508b-069718339edc@stressinduktion.org>
 <CAHmME9pTLFu3-4n6m_OMj5jVWGE-+yC-4CnkynD--H4Nt8_cpA@mail.gmail.com> <20161215210933.GY3207@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        David Laight <David.Laight@aculab.com>,
        Netdev <netdev@vger.kernel.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: kernel-hardening@lists.openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161215210933.GY3207@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 10:09 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, Dec 15, 2016 at 07:50:36PM +0100, Jason A. Donenfeld wrote:
>> There's no 32-bit platform
>> that will trap on a 64-bit unaligned access because there's no such
>> thing as a 64-bit access there. In short, we're fine.
>
> ARMv7 LPAE is a 32bit architecture that has 64bit load/stores IIRC.
>
> x86 has cmpxchg8b that can do 64bit things and very much wants the u64
> aligned.
>
> Also, IIRC we have a few platforms where u64 doesn't carry 8 byte
> alignment, m68k or something like that, but yes, you likely don't care.

Indeed, I stand corrected. But in any case, the use of __aligned(8) in
the patchset ensures that things are fixed and that we don't have this
issue.
