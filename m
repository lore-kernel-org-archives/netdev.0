From: Vincent Fortier <th0ma7@gmail.com>
Subject: Question/Problem - Connection reset - Ralink RT3290 - HP Split 13 x2
Date: Sat, 11 Oct 2014 08:24:21 -0400
Message-ID: <CALAySu+PKpcStTnFd6MiVm3LnnnD3DiUk_8ckWL0ZW3QtL91Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:54598 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbaJKMYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2014 08:24:23 -0400
Received: by mail-lb0-f182.google.com with SMTP id z11so4489143lbi.13
        for <netdev@vger.kernel.org>; Sat, 11 Oct 2014 05:24:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hopefully I'm at the right place to ask for help with the problem I
have with my Wifi connection:  It stops really really really often.
Sometimes it works for up to
an hour but usually within 10-15 minutes it just stop/reset and then
does it every few minutes... My presumption is that networkmanager is
able of restarting it most of the time until I get tired of it and
end-up restarting my laptop.  Note that the issue is not happening
under win8.1.

Tested using 3.16 & 3.17.

Device:
03:00.0 Network controller: Ralink corp. RT3290 Wireless 802.11n 1T/1R PCIe
    Subsystem: Hewlett-Packard Company Ralink RT3290LE 802.11bgn 1x1
Wi-Fi and Bluetooth 4.0 Combo Adapter
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 18
    Region 0: Memory at b0410000 (32-bit, non-prefetchable) [size=64K]
    Capabilities: <access denied>
    Kernel driver in use: rt2800pci

Getting the following messsages in syslog which I presume may be related:
Oct 10 17:45:36 brutus kernel: [    4.937845] ieee80211 phy0:
rt2x00_set_rt: Info - RT chipset 3290, rev 0015 detected
Oct 10 17:45:36 brutus kernel: [    4.941563] ieee80211 phy0:
rt2x00_set_rf: Info - RF chipset 3290 detected
Oct 10 17:45:36 brutus kernel: [    4.983868] ieee80211 phy0: Selected
rate control algorithm 'minstrel_ht'
Oct 10 17:45:37 brutus NetworkManager[877]: <info> rfkill0: found WiFi
radio killswitch (at
/sys/devices/pci0000:00/0000:
00:1c.2/0000:03:00.0/ieee80211/phy0/rfkill0)
(driver rt2800pci)
Oct 10 17:45:37 brutus kernel: [    5.610165] ieee80211 phy0:
rt2x00lib_request_firmware: Info - Loading firmware file 'rt3290.bin'
Oct 10 17:45:37 brutus kernel: [    5.611453] ieee80211 phy0:
rt2x00lib_request_firmware: Info - Firmware detected - version: 0.37
Oct 10 17:46:01 brutus kernel: [   29.621979] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:46:01 brutus kernel: [   30.070125] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 0 failed to flush
Oct 10 17:46:01 brutus kernel: [   30.230153] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:46:02 brutus kernel: [   30.678194] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:46:02 brutus kernel: [   31.190166] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 0 failed to flush
Oct 10 17:46:02 brutus kernel: [   31.350260] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:46:03 brutus kernel: [   31.798309] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:46:03 brutus kernel: [   32.246352] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 0 failed to flush
Oct 10 17:46:03 brutus kernel: [   32.406369] ieee80211 phy0:
....

It eventually renegociate network every few minutes:
[    6.987927] cfg80211: Calling CRDA for country: CA
[    6.991802] cfg80211: Regulatory domain changed to country: CA
[    6.991809] cfg80211:  DFS Master region: unset
[    6.991813] cfg80211:   (start_freq - end_freq @ bandwidth),
(max_antenna_gain, max_eirp), (dfs_cac_time)
[    6.991819] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz),
(300 mBi, 2700 mBm), (N/A)
[    6.991824] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz),
(300 mBi, 1700 mBm), (N/A)
[    6.991828] cfg80211:   (5250000 KHz - 5330000 KHz @ 40000 KHz),
(300 mBi, 2000 mBm), (0 s)
[    6.991832] cfg80211:   (5490000 KHz - 5710000 KHz @ 40000 KHz),
(300 mBi, 2000 mBm), (0 s)
[    6.991836] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz),
(300 mBi, 3000 mBm), (N/A)


Help much appreciated. Thnx in advance.

- vin
