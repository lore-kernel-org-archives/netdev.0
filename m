From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [RFC/PATCH 0/3] UDP memory usage accounting(take 2)
Date: Fri, 28 Sep 2007 22:36:02 +0900
Message-ID: <46FD0342.2030302@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: =?ISO-2022-JP?B?GyRCNUhGIxsoQiAbJEIxUUxAGyhC?=
	<yoshfuji@linux-ipv6.org>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	=?ISO-2022-JP?B?IhskQkBETFobKEJAUmVkSGF0Ig==?= <haoki@redhat.com>
To: Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:56128 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbXI1Scp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 14:32:45 -0400
Received: from mlsv16.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id B8E7C37AD7
	for <netdev@vger.kernel.org>; Sat, 29 Sep 2007 03:32:43 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set try to introduce memory usage accounting for 

UDP(currently ipv4 only).


3 points are improved along with some feedback.


(a) to improve scalability, avoiding atomic_*()s as small as

    possible

(b) avoiding UDP specific code in IP layer

(c) supporting socket destruction accounting


To implement (b), there is a side effect which affects

accounting on TCP socket. If you find the good solution

to avoid this side effect, please let me know.


Unfortunately, I don't have any NIC with UFO.

So this patch set is not tested with UFO supported

device.


This patch set is for 2.6.23-rc8.


I appreciate your comment/test/feedback.


Satoshi Oshima

