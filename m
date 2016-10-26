From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: concurrent rhashtable test failure
Date: Wed, 26 Oct 2016 11:11:46 +0200
Message-ID: <CAMuHMdVNXLxkAdxZxHt_YWpqaZnijpjEanCCud5euC+Duon_GA@mail.gmail.com>
References: <CAMuHMdWTqXaJAM-O+mmha=JbuyvvNxYyHuV6e4YK7oUkh9rCkA@mail.gmail.com>
 <20161026073337.GM5640@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Phil Sutter <phil@nwl.cc>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Thomas Graf <tgraf@suug.ch>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-m68k <linux-m68k@lists.linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20161026073337.GM5640@orbyte.nwl.cc>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 26, 2016 at 9:33 AM, Phil Sutter <phil@nwl.cc> wrote:
> On Mon, Oct 24, 2016 at 02:11:32PM +0200, Geert Uytterhoeven wrote:
>> On m68k/ARAnyM, test_rhashtable fails with:
>>
>>     Test failed: thread 0 returned: -4
>>
>> (-4 = -EINTR)
>
> How reproducible is this? I wonder why out of the ten threads only the
> first one fails.

100% reproducible.

Does it need SMP?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
