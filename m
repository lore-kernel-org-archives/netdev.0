From: "juice" <juice@swagman.org>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Mon, 24 Jan 2011 22:51:08 +0200
Message-ID: <b163b3ec7973e79dec94a21d5b0ab61b.squirrel@www.liukuma.net>
References: <D3F292ADF945FB49B35E96C94C2061B90ECC4FAC@nsmail.netscout.com>
    <13dbf221c875a931d408784495884998.squirrel@www.liukuma.net>
    <alpine.WNT.2.00.1101211400000.5816@JBRANDEB-DESK2.amr.corp.intel.com>
    <8ad1defdf427ceb7af94fad4d216b006.squirrel@www.liukuma.net>
    <30747065682effddc661b8cd235553d9.squirrel@www.liukuma.net>
    <1295886844.2755.36.camel@edumazet-laptop>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Loke, Chetan" <chetan.loke@netscout.com>,
	"Jon Zhou" <jon.zhou@jdsu.com>,
	"Stephen Hemming
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:15305 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752707Ab1AXUvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 15:51:14 -0500
In-Reply-To: <1295886844.2755.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> Please check what numbers you can get using dummy0 device instead of
> real ethernet driver.
>
> Here : (E5540  @ 2.53GHz) clone = 1
>
> Result: OK: 34775941(c34775225+d716) nsec, 100000000 (60byte,0frags)
>   2875551pps 1380Mb/sec (1380264480bps) errors: 0
>

My result on the machine (W3503 @ 2.40GHz):

Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
     frags: 0  delay: 0  clone_skb: 0  ifname: dummy0
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min: 10.10.11.2  dst_max:
     src_min:   src_max:
     src_mac: b6:b2:a2:f4:8e:dc dst_mac: 00:04:23:08:91:dc
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags:
Current:
     pkts-sofar: 10000000  errors: 0
     started: 1295902048722173us  stopped: 1295902052312514us idle: 3664us
     seq_num: 10000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x0  cur_daddr: 0x20b0a0a
     cur_udp_dst: 9  cur_udp_src: 9
     cur_queue_map: 0
     flows: 0
Result: OK: 3590341(c3586677+d3664) usec, 10000000 (60byte,0frags)
  2785250pps 1336Mb/sec (1336920000bps) errors: 0


Yours, Jussi Ohenoja


