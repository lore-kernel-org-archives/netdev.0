From: "Denys" <denys@visp.net.lb>
Subject: HFSC dangerous behaviour (not a bug)
Date: Mon, 29 Oct 2007 02:55:47 +0200
Message-ID: <20071029005547.M47431@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:40157 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbXJ2A4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 20:56:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Additionally, it doesn't show rate in stats (so it is difficult to measure, 
how much is really using each class).

qdisc hfsc 1: root default 200
 Sent 1392761062 bytes 965768 pkt (dropped 52, overlimits 1620539 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc bfifo 200: parent 1:200 limit 5000Kb
 Sent 3159118 bytes 17598 pkt (dropped 0, overlimits 0 requeues 177)
 rate 0bit 0pps backlog 0b 0p requeues 177
qdisc bfifo 910: parent 1:910 limit 2120000b
 Sent 514985563 bytes 360381 pkt (dropped 0, overlimits 0 requeues 314751)
 rate 0bit 0pps backlog 0b 0p requeues 314751
qdisc bfifo 1101: parent 1:1101 limit 1000000b
 Sent 139858294 bytes 94506 pkt (dropped 0, overlimits 0 requeues 85889)
 rate 0bit 0pps backlog 0b 0p requeues 85889
qdisc bfifo 1102: parent 1:1102 limit 1000000b
 Sent 96248464 bytes 65436 pkt (dropped 0, overlimits 0 requeues 58030)
 rate 0bit 0pps backlog 0b 0p requeues 58030
qdisc bfifo 1103: parent 1:1103 limit 1000000b
 Sent 111740612 bytes 75945 pkt (dropped 0, overlimits 0 requeues 66919)
 rate 0bit 0pps backlog 0b 0p requeues 66919
qdisc bfifo 923: parent 1:923 limit 375000b
 Sent 244333639 bytes 163399 pkt (dropped 0, overlimits 0 requeues 134977)
 rate 0bit 0pps backlog 0b 0p requeues 134977
qdisc bfifo 924: parent 1:924 limit 200000b
 Sent 101499905 bytes 68041 pkt (dropped 0, overlimits 0 requeues 43722)
 rate 0bit 0pps backlog 0b 0p requeues 43722
qdisc bfifo 925: parent 1:925 limit 200000b
 Sent 159908141 bytes 106077 pkt (dropped 51, overlimits 0 requeues 34702)
 rate 0bit 0pps backlog 0b 0p requeues 34702
qdisc bfifo 926: parent 1:926 limit 200000b
 Sent 21027140 bytes 14382 pkt (dropped 0, overlimits 0 requeues 10707)
 rate 0bit 0pps backlog 0b 0p requeues 10707
qdisc bfifo 955: parent 1:955 limit 500000b
 Sent 186 bytes 3 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0




--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

