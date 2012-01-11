From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 08:04:42 -0800
Message-ID: <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:56737 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755340Ab2AKQFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 11:05:04 -0500
Received: by werm1 with SMTP id m1so637792wer.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 08:05:03 -0800 (PST)
In-Reply-To: <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 7:05 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Sadly, that one makes no difference. I'll enable BRCM/BCMA debugging
> and see if that gives any more information, but will be unable to do
> much for the next few hours, so it will likely not be until this
> afternoon.

Ok, could do it now. But that really doesn't give much more
information. Here it is anyway:

[    0.746530] bcma-pci-bridge 0000:02:00.0: PCI INT A -> GSI 17
(level, low) -> IRQ 17
[    0.746544] bcma-pci-bridge 0000:02:00.0: setting latency timer to 64
[    0.746617] bcma: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800,
rev 0x22, class 0x0)
[    0.746646] bcma: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812,
rev 0x17, class 0x0)
[    0.746709] bcma: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev
0x0F, class 0x0)
[    0.746845] bcma: Switched to core: 0x800
[    0.746859] bcma: Found rev 6 PMU (capabilities 0x108C2606)
[    0.746880] bcma: Switched to core: 0x820
[    0.775510] bcma: Switched to core: 0x800
[    0.815750] bcma: Unsupported SPROM revision: 255
[    0.815804] bcma: No SPROM available
[    0.815909] bcma: Bus registered
[   41.797178] brcmsmac bcma0:0: mfg 4bf core 812 rev 23 class 0 irq 17
[   41.952030] bcma: Switched to core: 0x820
[   41.952050] bcma: Switched to core: 0x800
[   41.953881] ieee80211 phy0: wl0: brcms_b_attach: si_attach failed
[   41.956397] ieee80211 phy0: wl0: brcms_b_attach: failed with err 11
[   41.958443] ieee80211 phy0: wl0: brcms_c_attach: failed with err 11
[   41.960468] ieee80211 phy0: brcmsmac: attach() failed with code 11
[   41.962316] brcmsmac: brcms_bcma_probe: brcms_attach failed!
[   41.967275] brcms_module_init: register returned 0

hopefully this gives people *some* idea, but I'm not seeing anything.

         Linus
