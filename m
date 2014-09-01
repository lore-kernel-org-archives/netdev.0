From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] brcmfmac: BRCMFMAC should depend on HAS_DMA
Date: Mon, 1 Sep 2014 10:44:25 +0200
Message-ID: <CAMuHMdV2hV_r_OASkv+U-AGVov18qFOrAVm-nDHHPHXZ6fcxxg@mail.gmail.com>
References: <1409329464-768-1-git-send-email-geert@linux-m68k.org>
	<54042CA1.6010904@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brett Rudley <brudley@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	brcm80211-dev-list@broadcom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54042CA1.6010904@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arend,

On Mon, Sep 1, 2014 at 10:21 AM, Arend van Spriel <arend@broadcom.com> wrote:
>>   config BRCMFMAC
>>         tristate "Broadcom IEEE802.11n embedded FullMAC WLAN driver"
>> -       depends on CFG80211
>> +       depends on CFG80211A&&  HAS_DMA
>
> Not sure what happened here, but CFG80211 kconfig option did was not renamed
> as far as I know. Anyway, I would like to propose a different solution. Will

Oops, that was me typing the vim append-command twice :-(
Thanks for noticing!

> get back to you when I have it ready.

OK. Thanks again!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
