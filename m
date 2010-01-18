From: marco gaddoni <marco.gaddoni@gmail.com>
Subject: tg3 driver / BCM5722 dropping to 10Base-HD
Date: Mon, 18 Jan 2010 15:17:32 +0100
Message-ID: <3b2bc9d1001180617m8c2e8ddm2bc99099758e53c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:2978 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505Ab0ARORd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 09:17:33 -0500
Received: by fg-out-1718.google.com with SMTP id 22so717214fge.1
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 06:17:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

i have a dell with a BCM5722 driven by the tg3 driver.

this pc is connected to an unmanaged switch by micronet;
the connection is at 1000MBs.

the system is normally stable;
sometimes the connection get dropped to 10Mbs/HD.

i can get te connection back up to 1000Mbps
with an ethtool -t eth0.

do you have any idea on what is the cause of this ?
is this the wrong adderess?

please cc: me as i am not subscibed to netdev.

thank you in advance,
 marco,

02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5722
Gigabit Ethernet PCI Express
        Subsystem: Dell PowerEdge T300 Broadcom NetXtreme 57xx
        Flags: bus master, fast devsel, latency 0, IRQ 17
        Memory at dfef0000 (64-bit, non-prefetchable) [size=64K]
        Capabilities: [48] Power Management version 3
        Capabilities: [50] Vital Product Data <?>
        Capabilities: [58] Vendor Specific Information <?>
        Capabilities: [e8] Message Signalled Interrupts: Mask- 64bit+
Count=1/1 Enable-
        Capabilities: [d0] Express Endpoint, MSI 00
        Capabilities: [100] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSVoil-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO+ CmpltAbrt+
UnxCmplt+ RxOF- MalfTLP- ECRC- UnsupReq+ ACSVoil-
                UESvrt: DLP+ SDES+ TLP+ FCP+ CmpltTO- CmpltAbrt-
UnxCmplt- RxOF+ MalfTLP+ ECRC+ UnsupReq- ACSVoil-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                CESta:  RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalErr+
                AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
        Capabilities: [13c] Virtual Channel <?>
        Capabilities: [160] Device Serial Number ba-79-2e-fe-ff-b9-26-00
        Capabilities: [16c] Power Budgeting <?>
        Kernel driver in use: tg3
        Kernel modules: tg3


srvlinux:~ # ethtool -S eth0
NIC statistics:
     rx_octets: 11858646
     rx_fragments: 0
     rx_ucast_packets: 126925
     rx_mcast_packets: 0
     rx_bcast_packets: 370
     rx_fcs_errors: 0
     rx_align_errors: 0
     rx_xon_pause_rcvd: 0
     rx_xoff_pause_rcvd: 851
     rx_mac_ctrl_rcvd: 0
     rx_xoff_entered: 424
     rx_frame_too_long_errors: 0
     rx_jabbers: 0
     rx_undersize_packets: 0
     rx_in_length_errors: 0
     rx_out_length_errors: 0
     rx_64_or_less_octet_packets: 0
     rx_65_to_127_octet_packets: 0
     rx_128_to_255_octet_packets: 0
     rx_256_to_511_octet_packets: 0
     rx_512_to_1023_octet_packets: 0
     rx_1024_to_1522_octet_packets: 0
     rx_1523_to_2047_octet_packets: 0
     rx_2048_to_4095_octet_packets: 0
     rx_4096_to_8191_octet_packets: 0
     rx_8192_to_9022_octet_packets: 0
     tx_octets: 156635560
     tx_collisions: 0
     tx_xon_sent: 0
     tx_xoff_sent: 0
     tx_flow_control: 0
     tx_mac_errors: 0
     tx_single_collisions: 0
     tx_mult_collisions: 0
     tx_deferred: 0
     tx_excessive_collisions: 0
     tx_late_collisions: 0
     tx_collide_2times: 0
     tx_collide_3times: 0
     tx_collide_4times: 0
     tx_collide_5times: 0
     tx_collide_6times: 0
     tx_collide_7times: 0
     tx_collide_8times: 0
     tx_collide_9times: 0
     tx_collide_10times: 0
     tx_collide_11times: 0
     tx_collide_12times: 0
     tx_collide_13times: 0
     tx_collide_14times: 0
     tx_collide_15times: 0
     tx_ucast_packets: 323623
     tx_mcast_packets: 0
     tx_bcast_packets: 37
     tx_carrier_sense_errors: 0
     tx_discards: 0
     tx_errors: 0
     dma_writeq_full: 0
     dma_write_prioq_full: 0
     rxbds_empty: 0
     rx_discards: 0
     rx_errors: 0
     rx_threshold_hit: 0
     dma_readq_full: 0
     dma_read_prioq_full: 0
     tx_comp_queue_full: 0
     ring_set_send_prod_index: 0
     ring_status_update: 0
     nic_irqs: 0
     nic_avoided_irqs: 0
     nic_tx_threshold_hit: 0

srvlinux:~ # uname -a
Linux srvlinux 2.6.27.39-0.3-default #1 SMP 2009-11-23 12:57:38 +0100
x86_64 x86_64 x86_64 GNU/Linux

-- 
"Reality continues to ruin my life." - Calvin.
