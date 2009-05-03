From: Francis Moreau <francis.moro@gmail.com>
Subject: Re: v2.6.30-rc4: b44: eth0: BUG! Timeout waiting for bit 00000002 of
	register 42c to clear.
Date: Sun, 3 May 2009 19:12:36 +0200
Message-ID: <38b2ab8a0905031012m5d50b68es22e3c80cfa72fd60@mail.gmail.com>
References: <38b2ab8a0905030922x722a45f3gf0790b5b90b0f2b3@mail.gmail.com>
	 <200905031828.14468.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:41325 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbZECRMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2009 13:12:37 -0400
In-Reply-To: <200905031828.14468.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Florian,

On Sun, May 3, 2009 at 6:28 PM, Florian Fainelli <florian@openwrt.org> wrote:
>> I got this since I updated my kernel from 2.6.29 to 2.6.30-rc4.
>>
>> Let me know if you need more information.
>
> Is this seen on a Broadcom 47xx/53xx platform or on a computer with a PCI b44
> card ?
>

$ lspci -vv

06:01.0 Ethernet controller: Broadcom Corporation BCM4401-B0 100Base-TX (rev 02)
        Subsystem: Acer Incorporated [ALI] Device 0090
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64
        Interrupt: pin A routed to IRQ 21
        Region 0: Memory at d2000000 (32-bit, non-prefetchable) [size=8K]
        Capabilities: <access denied>
        Kernel driver in use: b44


Let me know if you need more details.

Thanks
-- 
Francis
