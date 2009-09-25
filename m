From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: r8169, enabling TX checksumming breaks things?
Date: Sat, 26 Sep 2009 02:18:54 +0300
Message-ID: <200909260218.54899.denys@visp.net.lb>
References: <200909230915.27854.denys@visp.net.lb> <200909231724.23132.denys@visp.net.lb> <1253754752.13176.19.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:37885 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945AbZIYXPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 19:15:07 -0400
In-Reply-To: <1253754752.13176.19.camel@obelisk.thedillows.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> This is the patch I have against HEAD, which Works For Me (TM). If I
> recall correctly the list in rtl8169_set_tso_csum() is from combing the
> vendor drivers, but I'm not 100% on that. Too much time has passed.
>
> I added the MAC version to the driver banner, which should make it
> easier to figure out which MAC you have, and to change that function if
> it does not work for you out of the box. It seems that some chips don't
> work with this at all, based on testing by Michael Riepe (XID 3c4000c0).
>
> As should be obvious, this isn't ready to go anywhere near upstream yet
> I think.
>
Applied to 2.6.31.1 (i cannot run latest git, it is loaded proxy, too much 
risk) (one reject only, fixed by hand).

[    0.793643] r8169 Gigabit Ethernet driver 2.3LK-NAPI-TSO loaded
[    0.793734] r8169 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.793842] r8169 0000:03:00.0: setting latency timer to 64
[    0.793898] r8169 0000:03:00.0: irq 27 for MSI/MSI-X
[    0.794188] eth0: RTL8168d/8111d (25) at 0xf8420000, 00:1c:c0:c2:4d:df, XID 
281000c0 IRQ 27
[    2.110317] r8169: eth0: link down
[    2.110396] r8169: eth0: link down
[    3.872590] r8169: eth0: link up

Working fine now, now when i enable TX checksumming it doesn't fail. I will 
run for a while with tx checksumming, and then i will run the rest and will 
do some performance measurements (by perf tool) and i will try on a little 
bit other model of motherboard.
Thanks a lot for your patch!
