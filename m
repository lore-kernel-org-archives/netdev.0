From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: does the broadcom bnx2x support RSS/multi queue
Date: Wed, 12 May 2010 00:31:55 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85D43@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og127.obsmtp.com ([64.18.2.210]:34591 "HELO
	exprod7og127.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752241Ab0ELHfG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 03:35:06 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi there

I am not sure if my Broadcom 10G nic driver(bnx2x) support RSS/multi queue

ibm-bc-53:/home/ruizhou/nprobe # uname -a
Linux ibm-bc-53 2.6.27.19-5-default #1 SMP 2009-02-28 04:40:21 +0100 x86_64 x86_64 x86_64 GNU/Linux

ibm-bc-53:/home/ruizhou/nprobe # ethtool -S eth5
NIC statistics:
     rx_bytes: 68100170
     rx_error_bytes: 0
     tx_bytes: 0
     tx_error_bytes: 0
     rx_ucast_packets: 201654
     rx_mcast_packets: 0
     rx_bcast_packets: 0
     tx_packets: 0
     tx_mac_errors: 0
     tx_carrier_errors: 0
     rx_crc_errors: 0
     rx_align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     tx_deferred: 0
     tx_excess_collisions: 0
     tx_late_collisions: 0
     tx_total_collisions: 0
     rx_fragments: 0
     rx_jabbers: 0
     rx_undersize_packets: 0
     rx_oversize_packets: 0
     tx_64_byte_packets: 0
     tx_65_to_127_byte_packets: 0
     tx_128_to_255_byte_packets: 0
     tx_256_to_511_byte_packets: 0
     tx_512_to_1023_byte_packets: 0
     tx_1024_to_1522_byte_packets: 0
     tx_1523_to_9022_byte_packets: 0
     rx_xon_frames: 0
     rx_xoff_frames: 0
     tx_xon_frames: 0
     tx_xoff_frames: 0
     rx_mac_ctrl_frames: 0
     rx_filtered_packets: 0
     rx_discards: 0
     rx_fw_discards: 0
     brb_discard: 0
     brb_truncate: 0
     rx_phy_ip_err_discards: 0
     rx_skb_alloc_discard: 0
     rx_csum_offload_errors: 6

the driver ver is:
bnx2x_main.c
#define DRV_MODULE_VERSION      "1.45.26"

looks not support?

thanks
jon




