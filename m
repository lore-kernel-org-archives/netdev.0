From: Ceriel Jacobs <linux-ide@crashplan.pro>
Subject: Re: r8168 is needed to enter P-state: Package State 6 (pc6) on Haswell
 hardware
Date: Mon, 06 Oct 2014 00:22:29 +0200
Message-ID: <5431C4A5.8050001@crashplan.pro>
References: <542B3829.3010108@crashplan.pro> <20141005165920.GA21926@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:56196 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbaJEWWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 18:22:34 -0400
In-Reply-To: <20141005165920.GA21926@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the requested "XID" dmesg line is:

[    1.479298] r8169 0000:03:00.0 eth0: RTL8168g/8111g at 
0xffffc90004752000, d0:50:99:0b:09:90, XID 0c000800 IRQ 27

Francois Romieu schreef op 05-10-14 om 18:59:
> Ceriel Jacobs <linux-ide@crashplan.pro> :
>> With in-kernel r8169 module, only P-state package C3 (pc3) can be reached
>> when enabling ASPM.
>>
>> Only after installing r8168 driver (and enabling ASPM), a Haswell Celeron
>> G1820/G1840 processer will enter package C6 state (pc6).
>
> Vanilla kernel r8169 driver logs a message that contains an "XID" string.
> Please grep for it in your dmesg so that I can narrow the search for
> meaningful differences in Realtek's r8168 driver.
>
> Thanks.
>
