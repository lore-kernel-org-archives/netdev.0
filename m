From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Sun, 18 Sep 2011 18:26:33 -0700
Message-ID: <CA+55aFzHOUaub9WJ7L_LGEGGkKdW-h3eV0MaUsCjdmUBKDGe_w@mail.gmail.com>
References: <20110918.022125.1554085675403900813.davem@davemloft.net>
 <CA+55aFxc1tMCXKBV33PVD5BybTLBpfJAEcObvoQwbwqbKOsp7g@mail.gmail.com>
 <20110918192333.GA1641@x4.trippels.de> <1316375164.31335.18.camel@edumazet-laptop>
 <20110918194818.GB1641@x4.trippels.de> <CA+55aFwmwYXzC_4q+XuEAx3ta6U-jf=NvMcAc-J+4DBxLm8Efg@mail.gmail.com>
 <1316378130.31335.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1316378130.31335.32.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 18, 2011 at 1:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> [PATCH] tcp: fix build error if !CONFIG_SYN_COOKIE
>
> commit 946cedccbd7387 (tcp: Change possible SYN flooding messages)
> added a build error if CONFIG_SYN_COOKIE=n

Christ Eric, you clearly didn't even compile-test this one either.

Which is pretty bad, considering that the whole and only *point* of
the patch is to make it compile.

The config option is CONFIG_SYN_COOKIES (with an 'S' at the end), but
your patch has 'CONFIG_SYN_COOKIE' (without the S).

Which means that now it doesn't compile when syncookies are *enabled*.

I really wanted to release -rc7 today. But no way am I applying these
kinds of totally untested patches. Can you guys please get your act
together?

PLEASE?

Stop with the "this might just work" crap. Because -rc7 is just too
late to dick around like that.

                       Linus
