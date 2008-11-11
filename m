From: ROUTE 66 - Catalin BOIE <cboie@route66.ro>
Subject: Strange TCP dump between a Linux and a Samsung phone
Date: Tue, 11 Nov 2008 16:05:02 +0200
Message-ID: <4919910E.6080700@route66.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.route66.ro ([91.201.80.3]:51921 "EHLO mail.route66.ro"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755858AbYKKOQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 09:16:04 -0500
Received: from cboie.route66.ro (cboie.route66.ro [192.168.2.60])
	(authenticated bits=0)
	by mail.route66.ro (8.14.2/8.14.2) with ESMTP id mABE53nM008090
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 16:05:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I have captured a strange dump between a Linux kernel
2.6.25.6-55.fc9.x86_64 and a Samsung device.
I looked at it and it seems that the Linux stack does not send any
retransmissions to Samsung device.
But, I want a competent look from you.

The connection is done over a 3G connection.
The capture was done on a router between the two endpoints.
c.66.com is the Linux machine, the other IP is the Samsung device.

The last packets of the capture are:
11:31:36.816467 IP 213.233.90.58.32119 > c.66.com.http: . ack 1238481
win 65535
11:31:37.814711 IP 213.233.90.58.32119 > c.66.com.http: . ack 1238481
win 65535
11:31:38.814366 IP 213.233.90.58.32119 > c.66.com.http: . ack 1238481
win 65535
11:31:39.099101 IP c.66.com.http > 213.233.90.58.32119: .
1238481:1239941(1460) ack 414 win 6432
11:31:39.774267 IP 213.233.90.58.32119 > c.66.com.http: . ack 1242861
win 65535
11:31:39.774430 IP c.66.com.http > 213.233.90.58.32119: .
1253081:1254541(1460) ack 414 win 6432
11:31:39.774439 IP c.66.com.http > 213.233.90.58.32119: .
1254541:1256001(1460) ack 414 win 6432
11:31:39.954781 IP 213.233.90.58.32119 > c.66.com.http: . ack 1242861
win 65535
11:31:39.954921 IP c.66.com.http > 213.233.90.58.32119: .
1256001:1257461(1460) ack 414 win 6432
11:31:40.135381 IP 213.233.90.58.32119 > c.66.com.http: . ack 1242861
win 65535
11:31:40.135519 IP c.66.com.http > 213.233.90.58.32119: .
1257461:1258921(1460) ack 414 win 6432
11:31:40.314255 IP 213.233.90.58.32119 > c.66.com.http: . ack 1242861
win 65535
11:31:40.314398 IP c.66.com.http > 213.233.90.58.32119: .
1242861:1244321(1460) ack 414 win 6432
11:31:40.974698 IP 213.233.90.58.32119 > c.66.com.http: . ack 1254541
win 65535
11:31:40.974849 IP c.66.com.http > 213.233.90.58.32119: .
1254541:1256001(1460) ack 414 win 6432
11:31:41.636247 IP 213.233.90.58.32119 > c.66.com.http: . ack 1258921
win 65535
11:31:41.636423 IP c.66.com.http > 213.233.90.58.32119: .
1258921:1260381(1460) ack 414 win 6432
11:31:41.636432 IP c.66.com.http > 213.233.90.58.32119: .
1260381:1261841(1460) ack 414 win 6432
11:31:41.636439 IP c.66.com.http > 213.233.90.58.32119: .
1261841:1263301(1460) ack 414 win 6432
11:31:52.564127 IP c.66.com.http > 213.233.90.58.32119: .
1258921:1260381(1460) ack 414 win 6432
11:31:53.765346 IP 213.233.90.58.32119 > c.66.com.http: . ack 1260381
win 65535
11:31:53.765534 IP c.66.com.http > 213.233.90.58.32119: .
1263301:1264761(1460) ack 414 win 6432
11:31:53.765547 IP c.66.com.http > 213.233.90.58.32119: .
1264761:1266221(1460) ack 414 win 6432
11:31:53.926119 IP 213.233.90.58.32119 > c.66.com.http: . ack 1260381
win 65535
11:31:53.926258 IP c.66.com.http > 213.233.90.58.32119: .
1266221:1267681(1460) ack 414 win 6432
11:31:53.945502 IP 213.233.90.58.32119 > c.66.com.http: . ack 1260381
win 65535
11:31:54.105085 IP 213.233.90.58.32119 > c.66.com.http: . ack 1260381
win 65535
11:31:54.925746 IP 213.233.90.58.32119 > c.66.com.http: . ack 1260381
win 65535
11:31:55.924180 IP 213.233.90.58.32119 > c.66.com.http: . ack 1260381
win 65535
11:31:56.945416 IP 213.233.90.58.32119 > c.66.com.http: . ack 1260381
win 65535
11:31:57.945049 IP 213.233.90.58.32119 > c.66.com.http: . ack 1260381
win 65535
11:31:58.945921 IP 213.233.90.58.32119 > c.66.com.http: . ack 1260381
win 65535
11:31:59.945681 IP 213.233.90.58.32119 > c.66.com.http: . ack 1260381
win 65535
11:32:00.944815 IP 213.233.90.58.32119 > c.66.com.http: . ack 1260381
win 65535
11:32:01.945018 IP 213.233.90.58.32119 > c.66.com.http: . ack 1260381
win 65535
11:32:02.946170 IP 213.233.90.58.32119 > c.66.com.http: . ack 1260381
win 65535
11:32:15.621126 IP c.66.com.http > 213.233.90.58.32119: .
1260381:1261841(1460) ack 414 win 6432
11:32:16.823395 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:16.823565 IP c.66.com.http > 213.233.90.58.32119: .
1267681:1269141(1460) ack 414 win 6432
11:32:16.823574 IP c.66.com.http > 213.233.90.58.32119: .
1269141:1270601(1460) ack 414 win 6432
11:32:16.983981 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:16.984137 IP c.66.com.http > 213.233.90.58.32119: .
1270601:1272061(1460) ack 414 win 6432
11:32:16.984147 IP c.66.com.http > 213.233.90.58.32119: .
1272061:1273521(1460) ack 414 win 6432
11:32:17.003214 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:17.143529 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:17.163862 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:17.983174 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:18.983839 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:19.983172 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:20.984122 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:21.983888 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:22.985082 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:24.002955 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:25.003203 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:26.004390 IP 213.233.90.58.32119 > c.66.com.http: . ack 1261841
win 65535
11:32:56.453482 IP 213.233.90.58.32119 > c.66.com.http: F 414:414(0) ack
1261841 win 65535
11:32:56.493122 IP c.66.com.http > 213.233.90.58.32119: . ack 415 win 6432
11:33:00.535158 IP c.66.com.http > 213.233.90.58.32119: .
1261841:1263301(1460) ack 415 win 6432
11:33:01.162502 IP 213.233.90.58.32119 > c.66.com.http: R
777650211:777650211(0) win 0

As you may see, the Samsung device keeps sending an ACK for 1261841 and
after some time closes the connection.
Why the Linux stack does no retransmissions?

Thank you very much!

-- 
Catalin BOIE
ROUTE 66
