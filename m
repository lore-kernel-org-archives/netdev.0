From: "Berck E. Nash" <flyboy@gmail.com>
Subject: sky2 hang still exists in 2.6.19-rc6 --Bug#396185?
Date: Tue, 28 Nov 2006 22:01:27 -0700
Message-ID: <456D1427.70205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:54600 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S933622AbWK2FBa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 00:01:30 -0500
Received: by py-out-1112.google.com with SMTP id a29so1409031pyi
        for <netdev@vger.kernel.org>; Tue, 28 Nov 2006 21:01:30 -0800 (PST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've been having problems with the sky2 ethernet driver from the very
beginning.  I have read the following:

http://marc.theaimsgroup.com/?l=linux-netdev&m=116384918914761&w=2

And the bug described still exists for me.  I'm running 2.6.19-rc6-mm1.

The only relevant console output:

[55022.353219] NETDEV WATCHDOG: eth0: transmit timed out
[55022.358356] sky2 eth0: tx timeout
[55022.361753] sky2 status report lost?

After that, the system is totally unresponsive and requires a hard reset.

The device is onboard lan on an ASUS P5W-DH Deluxe.  lspci -vv:

02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E
Gigabit Ethernet Controller (rev 20)
         Subsystem: ASUSTeK Computer Inc. Marvell 88E8053 Gigabit
Ethernet controller PCIe (Asus)
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
         Latency: 0, Cache Line Size: 16 bytes
         Interrupt: pin A routed to IRQ 315
         Region 0: Memory at fa9fc000 (64-bit, non-prefetchable) [size=16K]
         Region 2: I/O ports at c800 [size=256]
         Expansion ROM at fa9c0000 [disabled] [size=128K]
         Capabilities: [48] Power Management version 2
                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [50] Vital Product Data
         Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+
Queue=0/1 Enable+
                 Address: 00000000fee0300c  Data: 41a1
         Capabilities: [e0] Express Legacy Endpoint IRQ 0
                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0,
ExtTag-
                 Device: Latency L0s unlimited, L1 unlimited
                 Device: AtnBtn- AtnInd- PwrInd-
                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                 Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
                 Link: Latency L0s <256ns, L1 unlimited
                 Link: ASPM Disabled RCB 128 bytes CommClk+ ExtSynch-
                 Link: Speed 2.5Gb/s, Width x1


I'll be glad to help test anything I can...
Please cc me on any replies as I'm not subscribed.

Thanks!
Berck

