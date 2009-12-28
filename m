From: "Kristian Evensen" <kristian.evensen@gmail.com>
Subject: Strange TCP behavior over HSDPA
Date: Mon, 28 Dec 2009 13:56:22 +0100
Message-ID: <4b38aaf7.0f67f10a.0624.6a06@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:51278 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbZL1M4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 07:56:25 -0500
Received: by ewy19 with SMTP id 19so1746559ewy.21
        for <netdev@vger.kernel.org>; Mon, 28 Dec 2009 04:56:24 -0800 (PST)
Content-Language: no
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a laptop running Ubuntu 9.04 with the 2.6.32.2-kernel and the machine
connects to the internet using HSDPA. When transferring files (from the same
server) using TCP I notice that the connection often experience severe drops
in throughput. Often, it takes over a second for the (fast) retransmission
to arrive.

First I thought this might be due to poor network conditions, but when
testing tunnels (L2TP and PPTP) I noticed that the throughput was more
stable and the average higher. It seems like the retransmission is sent and
arrives quicker than without tunnels. The drops last for a shorter period of
time and does not affect the performance that much. Based on my
understanding of the tunneling protocols, they offer no reliability for data
and according to my ISP UDP and TCP packets are treated equally.

I have performed several experiments (adjusting the MTU, MSS and running the
tests from different places) trying to figure out why tunnels perform better
than without tunnels, but I have not been able to come up with an answer.
The different experiments all give the same result. So my question is, has
anyone experienced anything similar or have an idea as to why the tunnels
perform better?

The HSDPA-modems I have used are the Huawei E220 and Sierra Wireless Aircard
880u. If anyone is interested in looking at the packet dumps, they can be
found here [1] and here [2]. [1] is without tunnels and a typical packet
loss is shown at packet 1705, while [2] is without tunnels and a typical
packet loss is shown at 3381.

Thanks in advance for any help,
Kristian

[1] - http://heim.ifi.uio.no/~kristrev/hsdpa-captures/loss_hsdpa.pcap 
[2] - http://heim.ifi.uio.no/~kristrev/hsdpa-captures/loss_hsdpa_tunnel.pcap


