From: "Christoph Gysin" <christoph.gysin@fr33z3.org>
Subject: Re: 8139too in >=2.6.26: SIOCSIFFLAGS: Device or resource busy
Date: Thu, 11 Dec 2008 13:06:13 +0100
Message-ID: <6f67b0190812110406m144f69c5y820a20f57bce1026@mail.gmail.com>
References: <6f67b0190812100251u511d0aect4d082541977335d9@mail.gmail.com>
	 <20081210210435.GA30537@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:17365 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755282AbYLKMGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 07:06:14 -0500
Received: by yw-out-2324.google.com with SMTP id 9so442732ywe.1
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 04:06:13 -0800 (PST)
In-Reply-To: <20081210210435.GA30537@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/12/10 Francois Romieu <romieu@fr.zoreil.com>:
>> $ dmesg
>> 8139too Fast Ethernet driver 0.9.28
>> eth0: RealTek RTL8139 at 0xcf0580e4, 00:03:2d:0e:8e:75, IRQ 64767     <-- !?
>
> Indeed. Assuming you are using the same kernel .config, can you compare
> the dmesg from boot of 2.6.25 against 2.6.26 ?

Same kernel .config, dmesg output from 2.6.25:

$ modprobe 8139too debug=1
$ dmesg
8139too Fast Ethernet driver 0.9.28
rtl8139_init_board: PIO region size == 0x100
rtl8139_init_board: MMIO region size == 0x100
rtl8139_init_board: chipset id (1950351360) == index 8, 'RTL-8100B/8139D'
rtl8139_init_board: PCI PM wakeup
rtl8139_init_one: about to register device named eth%d (cf044000)...
eth0: RealTek RTL8139 at 0xd001e000, 00:03:2d:0e:8c:2f, IRQ 15
eth0:  Identified 8139 chip type 'RTL-8100B/8139D'

Chris
-- 
echo mailto: NOSPAM !#$.'<*>'|sed 's. ..'|tr "<*> !#:2" org@fr33z3
