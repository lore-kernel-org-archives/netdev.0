From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Thu, 23 Dec 2010 00:57:43 -0800
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F249D5F39C2@MILEXCH2.ds.jdsu.net>
References: <e1a7dc28b8b95e93d38edc418d59e89a.squirrel@www.liukuma.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "juice@swagman.org" <juice@swagman.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og105.obsmtp.com ([64.18.2.163]:41620 "HELO
	exprod7og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752739Ab0LWJDc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 04:03:32 -0500
In-Reply-To: <e1a7dc28b8b95e93d38edc418d59e89a.squirrel@www.liukuma.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of juice
> Sent: Thursday, December 23, 2010 1:16 PM
> To: Eric Dumazet; Stephen Hemminger; netdev@vger.kernel.org
> Subject: Re: Using ethernet device as efficient small packet generator
> 
> > Reaching 1Gbs should not be a problem (I was speaking about 10Gbps)
> > I reach link speed with my tg3 card and one single cpu :)
> > (Broadcom Corporation NetXtreme BCM5715S Gigabit Ethernet (rev a3))
> >
> > Please provide : ethtool -S eth0
> >
> 
> This is from the e1000 interface:
> 03:02.1 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet
> Controller (Copper) (rev 01)
> 
> root@a2labralinux:/home/juice# ethtool -S eth1
> NIC statistics:
>      rx_packets: 192069
>      tx_packets: 60000313
>      rx_bytes: 33850492
>      tx_bytes: 3840026215
>      rx_broadcast: 192069
>      tx_broadcast: 3
>      rx_multicast: 0
>      tx_multicast: 310
>      rx_errors: 0
>      tx_errors: 0
>      tx_dropped: 0
>      multicast: 0
>      collisions: 0
>      rx_length_errors: 0
>      rx_over_errors: 0
>      rx_crc_errors: 0
>      rx_frame_errors: 0
>      rx_no_buffer_count: 0
>      rx_missed_errors: 0
>      tx_aborted_errors: 0
>      tx_carrier_errors: 0
>      tx_fifo_errors: 0
>      tx_heartbeat_errors: 0
>      tx_window_errors: 0
>      tx_abort_late_coll: 0
>      tx_deferred_ok: 0
>      tx_single_coll_ok: 0
>      tx_multi_coll_ok: 0
>      tx_timeout_count: 0
>      tx_restart_queue: 1806437
>      rx_long_length_errors: 0
>      rx_short_length_errors: 0
>      rx_align_errors: 0
>      tx_tcp_seg_good: 0
>      tx_tcp_seg_failed: 0
>      rx_flow_control_xon: 0
>      rx_flow_control_xoff: 0
>      tx_flow_control_xon: 0
>      tx_flow_control_xoff: 0
>      rx_long_byte_count: 33850492
>      rx_csum_offload_good: 8978
>      rx_csum_offload_errors: 0
>      rx_header_split: 0
>      alloc_rx_buff_failed: 0
>      tx_smbus: 0
>      rx_smbus: 0
>      dropped_smbus: 0
> 
> 
> This is from the tg3 interface:
> 05:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5761
> Gigabit Ethernet PCIe (rev 10)
> 
> root@d8labralinux:/home/juice# ethtool -S eth2
> NIC statistics:
>      rx_octets: 10814
>      rx_fragments: 0
>      rx_ucast_packets: 20
>      rx_mcast_packets: 0
>      rx_bcast_packets: 26
>      rx_fcs_errors: 0
>      rx_align_errors: 0
>      rx_xon_pause_rcvd: 0
>      rx_xoff_pause_rcvd: 0
>      rx_mac_ctrl_rcvd: 0
>      rx_xoff_entered: 0
>      rx_frame_too_long_errors: 0
>      rx_jabbers: 0
>      rx_undersize_packets: 0
>      rx_in_length_errors: 0
>      rx_out_length_errors: 0
>      rx_64_or_less_octet_packets: 0
>      rx_65_to_127_octet_packets: 0
>      rx_128_to_255_octet_packets: 0
>      rx_256_to_511_octet_packets: 0
>      rx_512_to_1023_octet_packets: 0
>      rx_1024_to_1522_octet_packets: 0
>      rx_1523_to_2047_octet_packets: 0
>      rx_2048_to_4095_octet_packets: 0
>      rx_4096_to_8191_octet_packets: 0
>      rx_8192_to_9022_octet_packets: 0
>      tx_octets: 5120013863
>      tx_collisions: 0
>      tx_xon_sent: 0
>      tx_xoff_sent: 0
>      tx_flow_control: 0
>      tx_mac_errors: 0
>      tx_single_collisions: 0
>      tx_mult_collisions: 0
>      tx_deferred: 0
>      tx_excessive_collisions: 0
>      tx_late_collisions: 0
>      tx_collide_2times: 0
>      tx_collide_3times: 0
>      tx_collide_4times: 0
>      tx_collide_5times: 0
>      tx_collide_6times: 0
>      tx_collide_7times: 0
>      tx_collide_8times: 0
>      tx_collide_9times: 0
>      tx_collide_10times: 0
>      tx_collide_11times: 0
>      tx_collide_12times: 0
>      tx_collide_13times: 0
>      tx_collide_14times: 0
>      tx_collide_15times: 0
>      tx_ucast_packets: 80000034
>      tx_mcast_packets: 42
>      tx_bcast_packets: 40
>      tx_carrier_sense_errors: 0
>      tx_discards: 0
>      tx_errors: 0
>      dma_writeq_full: 0
>      dma_write_prioq_full: 0
>      rxbds_empty: 0
>      rx_discards: 0
>      rx_errors: 0
>      rx_threshold_hit: 0
>      dma_readq_full: 0
>      dma_read_prioq_full: 0
>      tx_comp_queue_full: 0
>      ring_set_send_prod_index: 0
>      ring_status_update: 0
>      nic_irqs: 0
>      nic_avoided_irqs: 0
>      nic_tx_threshold_hit: 0

Ethtool -S "My intel x520 10G nic" will show there are 8 rx/tx queues

I just made 5M pps with 64 bytes packet according to link given by eric Dumazet.
(connect the 2 ports with each other of the NIC, XEON E5540,kernel 2.6.32,set irq affinity, Noted that I have an abnormal ksoftirqd/2 which occupy 30%cpu even at idle state, so the result still has space to improve)

At another old kernel(2.6.16) with tg3 and bnx2 1G NIC,XEON E5450, I only got 490K pps(it is about 300Mbps,30% GE), I think the reason is multiqueue unsupported in this kernel.

I will do a test with 1Gb nic on the new kernel later.

> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
