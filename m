From: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
Subject: Possible wireless issue introduced in next-20140930
Date: Thu, 23 Oct 2014 01:17:26 -0200
Message-ID: <54487346.4080604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, everyone.

With next-20140930 my laptop does not work, i.e. after I enter my login 
and password in KDM, the entire system becomes unresponsive and I need 
to reset it in order to reboot (it does not even show the KDE splash 
screen).

It was working pretty fine with next-20140926.

I've also tested with next-20141022 and v3.18-rc1 and no luck.

git bisect pointed me to the commit below [1].  My wireless card is a 
RTL8191SEvA [2].

I need your help to troubleshoot this.

Thanks in advance.

[1]
commit 38506ecefab911785d5e1aa5889f6eeb462e0954
Author: Larry Finger <Larry.Finger@lwfinger.net>
Date:   Mon Sep 22 09:39:19 2014 -0500

     rtlwifi: rtl_pci: Start modification for new drivers

     Future patches will move the drivers for RTL8192EE and RTL8821AE
     from staging to the regular wireless tree. Here, the necessary features
     are added to the PCI driver. Other files are touched due to changes
     in the various data structs.

     Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
     Signed-off-by: John W. Linville <linville@tuxdriver.com>

[2]
$ lspci -vvv
02:00.0 Network controller: Realtek Semiconductor Co., Ltd. RTL8191SEvA 
Wireless LAN Controller (rev 10)
         Subsystem: Hewlett-Packard Company Device 1467
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Interrupt: pin A routed to IRQ 16
         Region 0: I/O ports at 3000 [size=256]
         Region 1: Memory at d3400000 (32-bit, non-prefetchable) [size=16K]
         Capabilities: <access denied>
         Kernel driver in use: rtl8192se

-- 
Murilo
