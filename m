From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: SIPHASH (was: Re: [GIT] Networking)
Date: Thu, 23 Feb 2017 11:21:42 +0100
Message-ID: <CAMuHMdWK8MZOErwOgpzEmNNysiY06_KTB_DKQtX0oPjizmNzqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jason,

On Wed, Feb 22, 2017 at 5:31 AM, David Miller <davem@davemloft.net> wrote:
> 3) Introduce SIPHASH and it's usage for secure sequence numbers and
>    syncookies.  From Jason A. Donenfeld.

> Jason A. Donenfeld (4):
>       siphash: add cryptographically secure PRF
>       siphash: implement HalfSipHash1-3 for hash tables
>       secure_seq: use SipHash in place of MD5
>       syncookies: use SipHash in place of SHA1

bloat-o-meter v4.10.. says:

    add/remove: 338/127 grow/shrink: 604/310 up/down: 86156/-24117 (62039)
    ...
    siphash_4u64                                   -    5006   +5006
    siphash_3u64                                   -    4298   +4298
    siphash_2u64                                   -    3582   +3582
    __siphash_unaligned                            -    3052   +3052
    __siphash_aligned                              -    3052   +3052
    siphash_3u32                                   -    2976   +2976
    siphash_1u64                                   -    2870   +2870
    siphash_1u32                                   -    2172   +2172
    ...

Do we need all of this builtin, unconditionally?

Thanks for your answer!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
