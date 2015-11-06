From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [GIT PULL] parisc architecture updates for v4.3
Date: Fri, 6 Nov 2015 15:10:21 +0100
Message-ID: <CAMuHMdVa1eXfN9gMC_ztUC=_g5RA3FQm2xivpvo1CnCJgwGrcQ@mail.gmail.com>
References: <20151025114934.GA11108@ls3530.box>
	<CA+55aFyJyY1FE_1k6Ks-2j4nYr7cbde_KvZ=J3fMUFJG5Okijg@mail.gmail.com>
	<56393D46.6060903@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	John David Anglin <dave.anglin@bell.net>,
	Network Development <netdev@vger.kernel.org>
To: Helge Deller <deller@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56393D46.6060903@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 4, 2015 at 12:03 AM, Helge Deller <deller@gmx.de> wrote:
>> Also, just looking at other things, we currently do have openrisc that has
>>
>>   #define L1_CACHE_BYTES 16
>>
>> so presumably openrisc would have had an issue with that XPS thing,
>
> and mn10300.

And several other architectures that define L1_CACHE_BYTES using
L1_CACHE_SHIFT.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
