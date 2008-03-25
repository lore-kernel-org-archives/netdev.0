From: "Avuton Olrich" <avuton@gmail.com>
Subject: Realtek RTL-8169 having receive errors
Date: Mon, 24 Mar 2008 17:17:16 -0700
Message-ID: <3aa654a40803241717g218f3d51pec42ecbb29835248@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.180]:46379 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611AbYCYARS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 20:17:18 -0400
Received: by el-out-1112.google.com with SMTP id v27so1525881ele.17
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2008 17:17:17 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On my production server, I recently updated to the latest git at the
time and I'm getting receive errors. I'd like to try to minimize the
resets, but I'd also like to help track down this problem. Is there a
way I can debug this, rather then downgrading back to 2.6.22.x (the
stable kernels in between didn't work for different reasons). Thanks!

Config: http://avuton.googlepages.com/config.gz

On commit: baadac8b10c5ac15ce3d26b68fa266c8889b163f

On device:
eth1      Link encap:Ethernet  HWaddr 00:14:85:35:CE:4D
          inet addr:10.0.0.1  Bcast:10.0.0.0  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:101004007 errors:106876 dropped:0 overruns:0 frame:106876
          TX packets:179565962 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:58365237754 (55661.4 Mb)  TX bytes:195800566752 (186729.9 Mb)
          Interrupt:23 Base address:0x2000


01:06.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169
Gigabit Ethernet (rev 10)
        Subsystem: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 16
        Region 0: I/O ports at 8000 [size=256]
        Region 1: Memory at f4005000 (32-bit, non-prefetchable) [size=256]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: r8169

-- 
avuton
--
 Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
