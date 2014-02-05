From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ipv4: Fix runtime WARNING in rtmsg_ifa()
Date: Wed, 5 Feb 2014 18:39:35 +0100
Message-ID: <CAMuHMdUpTrVeA=Uv8p167m9qNfyabcKtQCkNVyrUzCUZ7N0N7A@mail.gmail.com>
References: <1391585905-24851-1-git-send-email-geert@linux-m68k.org>
	<CAHA+R7Pw_A4SLVL5=3i47MeMiYAgMRTTyWV5yN5c6LmGvWbTGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7Pw_A4SLVL5=3i47MeMiYAgMRTTyWV5yN5c6LmGvWbTGA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 5, 2014 at 6:30 PM, Cong Wang <cwang@twopensource.com> wrote:
> On Tue, Feb 4, 2014 at 11:38 PM, Geert Uytterhoeven
> <geert@linux-m68k.org> wrote:
>> Apparently commit 5c766d642bcaffd0c2a5b354db2068515b3846cf ("ipv4:
>> introduce address lifetime") forgot to take into account the addition of
>> struct ifa_cacheinfo in inet_nlmsg_size(). Hence add it, like is already
>> done for ipv6.
>>
>> Suggested-by: Cong Wang <cwang@twopensource.com>
>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
>
> Seems a candidate for -stable.

Woops, yes. I thought this was a recent change, but I misread the year.
The bug has been present since v3.9-rc1.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
