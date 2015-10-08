From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v2 0/4] sh_eth: Remove obsolete platform_device_id entries
Date: Thu, 8 Oct 2015 15:49:05 +0200
Message-ID: <CAMuHMdUsB+9v6T=p0FivcymVFTFtOR8-tf2sOpOMBgV_CH7Hfw@mail.gmail.com>
References: <1444205657-25314-1-git-send-email-geert+renesas@glider.be>
	<20151008.051023.991121515814557831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20151008.051023.991121515814557831.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

[CC Arnd wearing the arm-soc merge hat]

On Thu, Oct 8, 2015 at 2:10 PM, David Miller <davem@davemloft.net> wrote:
> From: Geert Uytterhoeven <geert+renesas@glider.be>
> Date: Wed,  7 Oct 2015 10:14:13 +0200
>
>> Since commit 3d7608e4c169af03 ("ARM: shmobile: bockw: remove legacy
>> board file and config"), which is now in arm-soc/for-next, shmobile SoCs
>> are only supported in generic DT-only ARM multi-platform builds.
>> The sh_eth driver doesn't need to match platform devices by name
>> anymore, hence this series removes the corresponding platform_device_id
>> entries.
>>
>> Changes since v1:
>>   - Protect some data and functions by #ifdef CONFIG_OF to silence
>>     unused compiler warnings on SH,
>>   - New patches 3 and 4.
>
> Since that commit isn't in any of my trees why don't you merge this
> via arm-soc/for-next?

This series just changes the sh_eth driver. There's  no direct dependency on
the arm-soc changes. Hence I think the sh_eth changes should go in through
the netdev tree.

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
