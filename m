From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [kernel-hardening] Re: [PATCH v7 3/6] random: use SipHash in
 place of MD5
Date: Thu, 22 Dec 2016 16:05:53 +0100
Message-ID: <5c306c80-3499-8b92-21d0-c197f30ce326@stressinduktion.org>
References: <20161216030328.11602-1-Jason@zx2c4.com>
 <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com>
 <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
 <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
 <20161222054125.lzxhd6ctovm3wk4p@thunk.org>
 <1482410840.2472.2.camel@stressinduktion.org>
 <CAHmME9r_zTHo=dxRRK6UrjJ_dKV14yYsZsxCc362z4CPoVkddw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Theodore Ts'o <tytso@mit.edu>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
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
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        kernel-hardening@lists.openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9r_zTHo=dxRRK6UrjJ_dKV14yYsZsxCc362z4CPoVkddw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22.12.2016 14:10, Jason A. Donenfeld wrote:
> On Thu, Dec 22, 2016 at 1:47 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> following up on what appears to be a random subject: ;)
>>
>> IIRC, ext4 code by default still uses half_md4 for hashing of filenames
>> in the htree. siphash seems to fit this use case pretty good.
> 
> I saw this too. I'll try to address it in v8 of this series.

This change would need a new version of the ext4 super block, because
you should not change existing file systems.
