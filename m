From: Vincent Fortier <th0ma7@gmail.com>
Subject: Problem - Connection reset - Ralink RT3290 - HP Split 13 x2
Date: Fri, 10 Oct 2014 18:39:11 -0400
Message-ID: <CALAySu+SsT5V84Bhd6Ln2yUrLV5MGpdW7sUODhA-N8oeWLXWpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:47872 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbaJJWjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 18:39:12 -0400
Received: by mail-la0-f54.google.com with SMTP id gm9so4132226lab.27
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 15:39:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My connection stop really really often.  Sometimes it works for up to
an hour but usually within 10-15 minutes it just stop/reset.
Presumably networkmanager restarts it.

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

Getting the following messsages in syslog:
Oct 10 17:45:36 brutus kernel: [    4.937845] ieee80211 phy0:
rt2x00_set_rt: Info - RT chipset 3290, rev 0015 detected
Oct 10 17:45:36 brutus kernel: [    4.941563] ieee80211 phy0:
rt2x00_set_rf: Info - RF chipset 3290 detected
Oct 10 17:45:36 brutus kernel: [    4.983868] ieee80211 phy0: Selected
rate control algorithm 'minstrel_ht'
Oct 10 17:45:37 brutus NetworkManager[877]: <info> rfkill0: found WiFi
radio killswitch (at
/sys/devices/pci0000:00/0000:00:1c.2/0000:03:00.0/ieee80211/phy0/rfkill0)
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
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:46:04 brutus kernel: [   32.918438] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:49:01 brutus kernel: [  210.316739] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:49:02 brutus kernel: [  210.764804] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:49:02 brutus kernel: [  211.276854] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:49:03 brutus kernel: [  211.724905] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:50:04 brutus kernel: [  272.647105] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:51:27 brutus kernel: [  355.999778] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:51:28 brutus kernel: [  357.183902] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:53:11 brutus kernel: [  460.055960] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:57:10 brutus kernel: [  699.528350] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 0 failed to flush
Oct 10 17:57:11 brutus kernel: [  699.688416] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 17:57:11 brutus kernel: [  700.136713] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 18:01:10 brutus kernel: [  939.336908] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush
Oct 10 18:01:11 brutus kernel: [  939.801190] ieee80211 phy0:
rt2x00queue_flush_queue: Warning - Queue 2 failed to flush


Help much appreciated. Thnx in advance.

- vin
