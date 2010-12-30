From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Wed, 29 Dec 2010 20:11:48 -0500
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90ECC4FAC@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Jon Zhou" <Jon.Zhou@jdsu.com>, <juice@swagman.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og106.obsmtp.com ([64.18.1.191]:45714 "HELO
	exprod6og106.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754218Ab0L3BLv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 20:11:51 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Jon Zhou
> Sent: December 23, 2010 3:58 AM
> To: juice@swagman.org; Eric Dumazet; Stephen Hemminger;
> netdev@vger.kernel.org
> Subject: RE: Using ethernet device as efficient small packet generator
> 
> 
> At another old kernel(2.6.16) with tg3 and bnx2 1G NIC,XEON E5450, I
> only got 490K pps(it is about 300Mbps,30% GE), I think the reason is
> multiqueue unsupported in this kernel.
> 
> I will do a test with 1Gb nic on the new kernel later.
> 


I can hit close to 1M pps(first time every time) w/ a 64-byte payload on
my VirtualMachine(running 2.6.33) via vmxnet3 vNIC - 


[root@localhost ~]# cat /proc/net/pktgen/eth2
Params: count 0  min_pkt_size: 60  max_pkt_size: 60
     frags: 0  delay: 0  clone_skb: 0  ifname: eth2
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min: 192.168.222.2  dst_max:
        src_min:   src_max:
     src_mac: 00:50:56:b1:00:19 dst_mac: 00:50:56:c0:00:3e
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags:
Current:
     pkts-sofar: 59241012  errors: 0
     started: 1898437021us  stopped: 1957709510us idle: 9168us
     seq_num: 59241013  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x0  cur_daddr: 0x2dea8c0
     cur_udp_dst: 9  cur_udp_src: 9
     cur_queue_map: 0
     flows: 0
Result: OK: 59272488(c59263320+d9168) nsec, 59241012 (60byte,0frags)
  999468pps 479Mb/sec (479744640bps) errors: 0



Chetan
