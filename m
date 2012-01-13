From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: brcmsmac: 3.2.0-06100: no device shown (and hangs in
 3.2.0-rc7)
Date: Fri, 13 Jan 2012 14:36:57 +0100
Message-ID: <4F103379.2050904@broadcom.com>
References: <20120113124559.GA2260@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
To: "Nico Schottelius" <nico-linux-20120113@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120113124559.GA2260@schottelius.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/13/2012 01:45 PM, Nico Schottelius wrote:
> Hello,
> 
> with 3.2.0-06100-ge343a89 brcmsmac does not get autoloaded anymore
> from udev. Loading it manually returns in dmesg:
> 
> --------------------------------------------------------------------------------
> [  247.495705] bcma: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800,
> rev 0x22, class 0x0)
> [  247.495749] bcma: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812,
> rev 0x17, class 0x0)
> [  247.495832] bcma: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev
> 0x0F, class 0x0)
> [  247.560553] bcma: Unsupported SPROM revision: 255
> [  247.560563] bcma: No SPROM available
> [  247.560852] bcma: Bus registered
> [  247.611789] brcmsmac bcma0:0: mfg 4bf core 812 rev 23 class 0 irq 17
> [  247.634051] ieee80211 phy0: wl0: brcms_b_attach: si_attach failed
> [  247.634062] ieee80211 phy0: wl0: brcms_b_attach: failed with err 11
> [  247.634069] ieee80211 phy0: wl0: brcms_c_attach: failed with err 11
> [  247.634111] ieee80211 phy0: brcmsmac: attach() failed with code 11
> [  247.634128] brcmsmac: brcms_bcma_probe: brcms_attach failed!
> --------------------------------------------------------------------------------
> 
> And ip does not show any device:
> 
> --------------------------------------------------------------------------------
> [13:37] brief:~% ip l
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> --------------------------------------------------------------------------------
> 
> With 3.2.0-rc7 the device works, until it begins to hang. As reported
> many times before.  As I've switched the environment, it is very good
> probable that an AP on channel 13 is in range.
> 
> Attached both dmesg/lsmod/configs.
> 
> Cheers,
> 
> Nico
> 

Could this be on your MacBook Air? If so, Linus has flagged and solved
this issue (see thread "brcm80211 breakage" on netdev mailer).

Gr. AvS
