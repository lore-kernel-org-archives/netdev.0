From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: ixgbe - problem with packet/bytes count on all queues
Date: Thu, 13 May 2010 21:01:07 +0200
Message-ID: <4BEC4C73.8080108@itcare.pl>
References: <4BCACD5A.6070809@itcare.pl> <alpine.WNT.2.00.1005111058150.7656@jbrandeb-desk1.amr.corp.intel.com> <4BE9B2C8.8040909@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r242-33.iq.pl ([86.111.242.33]:46512 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757360Ab0EMTBL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 15:01:11 -0400
In-Reply-To: <4BE9B2C8.8040909@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-05-11 21:40, Pawe=C5=82 Staszewski pisze:
> W dniu 2010-05-11 20:00, Brandeburg, Jesse pisze:
>>
>> On Sun, 18 Apr 2010, Pawe=C5=82 Staszewski wrote:
>>
>>> Hello
>>>
>>> I want to ask is this a normal behavior of ixgb driver and 82598EB =
nic.
>>> look for tx_queue_7 stats:
>> Hi, sorry no-one replied.
>>
> Thanks for reply :)
>>>    ethtool -S eth2
>>> NIC statistics:
>>>        rx_packets: 35103252
>>>        tx_packets: 1770371731
>>>        rx_bytes: 3602052416
>>>        tx_bytes: 1369778276
>>>        rx_pkts_nic: 138121006018
>>>        tx_pkts_nic: 122033163226
>>>        rx_bytes_nic: 101484528847981
>>>        tx_bytes_nic: 92258799092069
>>>        lsc_int: 1
>>>        tx_busy: 0
>>>        non_eop_descs: 0
>>>        rx_errors: 0
>>>        tx_errors: 0
>>>        rx_dropped: 0
>>>        tx_dropped: 0
>>>        multicast: 490226
>>>        broadcast: 124104912
>>>        rx_no_buffer_count: 0
>>>        collisions: 0
>>>        rx_over_errors: 0
>>>        rx_crc_errors: 0
>>>        rx_frame_errors: 0
>>>        hw_rsc_aggregated: 0
>>>        hw_rsc_flushed: 0
>>>        fdir_match: 0
>>>        fdir_miss: 0
>>>        rx_fifo_errors: 0
>>>        rx_missed_errors: 0
>>>        tx_aborted_errors: 0
>>>        tx_carrier_errors: 0
>>>        tx_fifo_errors: 0
>>>        tx_heartbeat_errors: 0
>>>        tx_timeout_count: 0
>>>        tx_restart_queue: 111130
>>>        rx_long_length_errors: 38599
>>>        rx_short_length_errors: 0
>>>        tx_flow_control_xon: 0
>>>        rx_flow_control_xon: 0
>>>        tx_flow_control_xoff: 0
>>>        rx_flow_control_xoff: 0
>>>        rx_csum_offload_errors: 1554191
>>>        alloc_rx_page_failed: 0
>>>        alloc_rx_buff_failed: 0
>>>        rx_no_dma_resources: 0
>>>        tx_queue_0_packets: 108685351623
>>>        tx_queue_0_bytes: 79701402025544
>>>        tx_queue_1_packets: 3988024698
>>>        tx_queue_1_bytes: 3353530467775
>>>        tx_queue_2_packets: 1893305707
>>>        tx_queue_2_bytes: 1705357186034
>>>        tx_queue_3_packets: 1787852613
>>>        tx_queue_3_bytes: 1518632482370
>>>        tx_queue_4_packets: 1843108684
>>>        tx_queue_4_bytes: 1641474602504
>>>        tx_queue_5_packets: 1882637467
>>>        tx_queue_5_bytes: 1629905766993
>>>        tx_queue_6_packets: 1952759802
>>>        tx_queue_6_bytes: 1680666591771
>>>        tx_queue_7_packets: 0
>>>        tx_queue_7_bytes: 0
>>>        rx_queue_0_packets: 17361735592
>>>        rx_queue_0_bytes: 12585728518077
>>>        rx_queue_1_packets: 17194262916
>>>        rx_queue_1_bytes: 12518731583464
>>>        rx_queue_2_packets: 17342312348
>>>        rx_queue_2_bytes: 12734959063176
>>>        rx_queue_3_packets: 17367632051
>>>        rx_queue_3_bytes: 12656219984521
>>>        rx_queue_4_packets: 17150307164
>>>        rx_queue_4_bytes: 12408526754019
>>>        rx_queue_5_packets: 17206721842
>>>        rx_queue_5_bytes: 12470666039893
>>>        rx_queue_6_packets: 17202210572
>>>        rx_queue_6_bytes: 12431429298950
>>>        rx_queue_7_packets: 17295822822
>>>        rx_queue_7_bytes: 12573299488239
>>>
>>> and here look at multiq queue number 8:
>>> tc -s -d class show dev eth2
>>> class multiq 1:1 parent 1:
>>>    Sent 6905560675905 bytes 510743840 pkt (dropped 0, overlimits 0
>>> requeues 0)
>>>    backlog 0b 0p requeues 0
>>> class multiq 1:2 parent 1:
>>>    Sent 280699743990 bytes 330210442 pkt (dropped 0, overlimits 0=20
>>> requeues 0)
>>>    backlog 0b 0p requeues 0
>>> class multiq 1:3 parent 1:
>>>    Sent 128528666971 bytes 142053106 pkt (dropped 0, overlimits 0=20
>>> requeues 0)
>>>    backlog 0b 0p requeues 0
>>> class multiq 1:4 parent 1:
>>>    Sent 123086710694 bytes 140454119 pkt (dropped 0, overlimits 0=20
>>> requeues 0)
>>>    backlog 0b 0p requeues 0
>>> class multiq 1:5 parent 1:
>>>    Sent 121027779083 bytes 146164066 pkt (dropped 0, overlimits 0=20
>>> requeues 0)
>>>    backlog 0b 0p requeues 0
>>> class multiq 1:6 parent 1:
>>>    Sent 116245520195 bytes 141597610 pkt (dropped 0, overlimits 0=20
>>> requeues 0)
>>>    backlog 0b 0p requeues 0
>>> class multiq 1:7 parent 1:
>>>    Sent 133310553887 bytes 151141714 pkt (dropped 0, overlimits 0=20
>>> requeues 0)
>>>    backlog 0b 0p requeues 0
>>> class multiq 1:8 parent 1:
>>>    Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>>    backlog 0b 0p requeues 0
>>>
>>> Is that normal that driver don't use queue number 8 ?
>> This seems extremely unusual, can you tell us what kernel version yo=
u're
>> using and what kind of test you're running?
>>
> Kernel 2.6.33.1
> Traffic type - normal Internet traffic from many users.
> 2Gbit/s RX + 2.6Gbit/s TX
>
> tc -s -d qdisc show dev eth2
> qdisc mq 0: root
>  Sent 71590101434962 bytes 2410582579 pkt (dropped 0, overlimits 0=20
> requeues 199799)
>  backlog 0b 0p requeues 199799
>
> Configuration for this nic:
> 4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP=
=20
> qlen 10000
> 8: vlan0100@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 9: vlan0101@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 10: vlan0102@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 11: vlan0103@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 12: vlan0104@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 13: vlan0105@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 14: vlan0106@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 15: vlan0107@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 16: vlan0108@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 17: vlan0109@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 18: vlan0110@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 19: vlan0111@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 20: vlan0112@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 21: vlan0113@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 22: vlan0140@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 23: vlan0141@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 24: vlan0143@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 25: vlan0300@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 26: vlan0114@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 27: vlan0450@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 28: vlan0401@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 29: vlan0402@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 30: vlan0301@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 31: vlan0302@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 32: vlan0303@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 33: vlan0304@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 34: vlan0305@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 35: vlan0306@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 36: vlan0307@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 37: vlan0308@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 38: vlan0309@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 39: vlan0310@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 40: vlan0311@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 41: vlan0312@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 42: vlan0313@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 43: vlan0403@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 44: vlan0314@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 45: vlan0315@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 46: vlan0316@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 47: vlan0317@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 48: vlan0318@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 49: vlan0404@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 50: vlan0405@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 51: vlan0115@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 52: vlan0406@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 53: vlan0116@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 54: vlan0490@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 55: vlan0491@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 56: vlan0319@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 57: vlan0320@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 58: vlan0321@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 59: vlan0322@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 60: vlan0323@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 61: vlan0324@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 62: vlan0325@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 63: vlan0326@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 64: vlan0327@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 65: vlan0328@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 66: vlan0329@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 67: vlan0330@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 68: vlan0331@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 69: vlan0332@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 70: vlan0333@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 71: vlan0334@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 72: vlan0335@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 73: vlan0336@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 74: vlan0337@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 75: vlan0338@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 76: vlan0339@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 77: vlan0340@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 78: vlan0341@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 79: vlan0342@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 80: vlan0343@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 81: vlan0344@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 82: vlan0345@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 83: vlan0117@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 84: vlan0118@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 85: vlan0119@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc m=
q=20
> state UP qlen 100
> 86: vlan0120@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 87: vlan0121@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 88: vlan0122@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 89: vlan0407@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 90: vlan0408@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 91: vlan0409@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 92: vlan0410@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 93: vlan0411@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 94: vlan0430@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 95: vlan0431@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 96: vlan0432@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 97: vlan0433@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 98: vlan0434@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 99: vlan0435@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 100: vlan0436@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 101: vlan0437@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 102: vlan0438@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 103: vlan0439@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 104: vlan0440@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 105: vlan0451@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 106: vlan0452@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 107: vlan0453@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 108: vlan0454@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 109: vlan0455@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 110: vlan0456@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 111: vlan0457@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 112: vlan0458@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 113: vlan0459@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 114: vlan0461@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 115: vlan0202@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 116: vlan0460@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 117: vlan0462@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 118: vlan0463@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 119: vlan0464@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 120: vlan0203@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 121: vlan0503@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 122: vlan0504@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 123: vlan0130@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 124: vlan0131@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 125: vlan0132@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 126: vlan0133@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 127: vlan0134@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 128: vlan0135@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 129: vlan0136@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 130: vlan0137@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 131: vlan0138@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 132: vlan0123@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 133: vlan0124@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 134: vlan0125@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 135: vlan0126@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 136: vlan0127@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 137: vlan0128@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 138: vlan0129@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 139: vlan0139@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 140: vlan0465@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 141: vlan0466@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 142: vlan0467@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 143: vlan0468@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 144: vlan0469@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 145: vlan0470@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 146: vlan0471@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 147: vlan0472@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 148: vlan0473@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 149: vlan0215@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 150: vlan0144@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 151: vlan0145@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 152: vlan0146@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 153: vlan0147@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 154: vlan0148@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 155: vlan0150@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 156: vlan0151@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 157: vlan0152@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 158: vlan0153@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> hfsc state UP qlen 100
> 159: vlan0412@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 160: vlan0413@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 161: vlan0414@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 162: vlan0415@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 163: vlan0416@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 164: vlan0154@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 165: vlan0155@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 166: vlan0156@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 167: vlan0157@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 168: vlan0158@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 169: vlan0159@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 170: vlan0160@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 171: vlan0161@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 172: vlan0162@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
> 173: vlan0163@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc=20
> noqueue state UP qlen 100
>
> more info about nic:
> ethtool -i eth2
> driver: ixgbe
> version: 2.0.44-k2
> firmware-version: 1.12-2
> bus-info: 0000:01:00.0
>
> ethtool -k eth2
> Offload parameters for eth2:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: off
> generic-receive-offload: off
> large-receive-offload: off
>
>
>
> and other weird thing is after delete qdisc:
> I think this is also not normal.
>
> tc qdisc del dev eth2 root
> tc -s -d class show dev eth2
> class mq :1 root
>  Sent 2608239 bytes 3000 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :2 root
>  Sent 3831841 bytes 3301 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :3 root
>  Sent 3518993 bytes 4016 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :4 root
>  Sent 1750040 bytes 2657 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :5 root
>  Sent 740596 bytes 1221 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :6 root
>  Sent 143782921 bytes 210547 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :7 root
>  Sent 3935866 bytes 5059 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :8 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :9 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :a root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :b root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :c root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :d root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :e root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :f root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :10 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :11 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :12 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :13 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :14 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :15 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :16 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :17 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :18 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :19 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :1a root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :1b root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :1c root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :1d root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :1e root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :1f root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :20 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :21 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :22 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :23 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :24 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :25 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :26 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :27 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :28 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :29 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :2a root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :2b root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :2c root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :2d root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :2e root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :2f root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :30 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :31 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :32 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :33 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :34 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :35 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :36 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :37 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :38 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :39 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :3a root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :3b root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :3c root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :3d root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :3e root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :3f root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :40 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :41 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :42 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :43 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :44 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :45 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :46 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :47 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :48 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :49 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :4a root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :4b root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :4c root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :4d root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :4e root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :4f root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :50 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :51 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :52 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :53 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :54 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :55 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :56 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :57 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :58 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :59 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :5a root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :5b root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :5c root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :5d root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :5e root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :5f root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :60 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :61 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :62 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :63 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :64 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :65 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :66 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :67 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :68 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :69 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :6a root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :6b root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :6c root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :6d root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :6e root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :6f root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :70 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :71 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :72 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :73 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :74 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :75 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :76 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :77 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :78 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :79 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :7a root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :7b root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :7c root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :7d root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :7e root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :7f root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :80 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>
>
> Normal i have multiq qdisc attached to device - and no difference whe=
n=20
> this is bfifo, pfifo or multiq
> tc qdisc add dev eth2 root handle 1: multiq
> then
>  tc -s -d class show dev eth2
> class multiq 1:1 parent 1:
>  Sent 2458266 bytes 3288 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class multiq 1:2 parent 1:
>  Sent 6259789 bytes 5390 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class multiq 1:3 parent 1:
>  Sent 4451430 bytes 5457 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class multiq 1:4 parent 1:
>  Sent 2915648 bytes 3917 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class multiq 1:5 parent 1:
>  Sent 1156897 bytes 1761 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class multiq 1:6 parent 1:
>  Sent 181776227 bytes 255856 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class multiq 1:7 parent 1:
>  Sent 5510686 bytes 6832 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class multiq 1:8 parent 1:
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>
>
>
>> it almost seems that there is an off by one somewhere, what kind of
>> traffic is being transmitted?
>>
>> Jesse
>>
>>
Aditional info for this:

After some time of working the only counters that works are:
      tx_queue_0_packets: 3611561261
      tx_queue_0_bytes: 2855348411016

And on the rest tx queues i see that counters are stopped.

  ethtool -S eth2
NIC statistics:
      rx_packets: 4107258563
      tx_packets: 3812022192
      rx_bytes: 1138855016
      tx_bytes: 2436290757
      rx_pkts_nic: 4125112688
      tx_pkts_nic: 3812022192
      rx_bytes_nic: 2931206969763
      tx_bytes_nic: 3058175756001
      lsc_int: 2
      tx_busy: 0
      non_eop_descs: 0
      rx_errors: 0
      tx_errors: 0
      rx_dropped: 0
      tx_dropped: 0
      multicast: 14179
      broadcast: 5326455
      rx_no_buffer_count: 0
      collisions: 0
      rx_over_errors: 0
      rx_crc_errors: 0
      rx_frame_errors: 0
      hw_rsc_aggregated: 0
      hw_rsc_flushed: 0
      fdir_match: 0
      fdir_miss: 0
      rx_fifo_errors: 0
      rx_missed_errors: 0
      tx_aborted_errors: 0
      tx_carrier_errors: 0
      tx_fifo_errors: 0
      tx_heartbeat_errors: 0
      tx_timeout_count: 0
      tx_restart_queue: 790
      rx_long_length_errors: 38
      rx_short_length_errors: 0
      tx_flow_control_xon: 0
      rx_flow_control_xon: 0
      tx_flow_control_xoff: 0
      rx_flow_control_xoff: 0
      rx_csum_offload_errors: 15663
      alloc_rx_page_failed: 0
      alloc_rx_buff_failed: 0
      rx_no_dma_resources: 0
      tx_queue_0_packets: 3611561261
      tx_queue_0_bytes: 2855348411016
      tx_queue_1_packets: 55713901
      tx_queue_1_bytes: 51724064701
      tx_queue_2_packets: 32077638
      tx_queue_2_bytes: 26637159254
      tx_queue_3_packets: 30157483
      tx_queue_3_bytes: 22398763585
      tx_queue_4_packets: 27389438
      tx_queue_4_bytes: 21974458604
      tx_queue_5_packets: 26757646
      tx_queue_5_bytes: 23280148038
      tx_queue_6_packets: 28364824
      tx_queue_6_bytes: 24730261889
      tx_queue_7_packets: 0
      tx_queue_7_bytes: 0
      rx_queue_0_packets: 495752660
      rx_queue_0_bytes: 326420962428
      rx_queue_1_packets: 519436668
      rx_queue_1_bytes: 369318739796
      rx_queue_2_packets: 519817774
      rx_queue_2_bytes: 367813366140
      rx_queue_3_packets: 526592761
      rx_queue_3_bytes: 378001222304
      rx_queue_4_packets: 502134859
      rx_queue_4_bytes: 354272049076
      rx_queue_5_packets: 523547673
      rx_queue_5_bytes: 383190146632
      rx_queue_6_packets: 527252376
      rx_queue_6_bytes: 372095739303
      rx_queue_7_packets: 510577598
      rx_queue_7_bytes: 347093806181

>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

