From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [RFC/PATCH 0/3] UDP memory usage accounting
Date: Fri, 21 Sep 2007 21:18:07 +0900
Message-ID: <46F3B67F.4030007@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: haoki@redhat.com,
	=?ISO-2022-JP?B?GyRCNUhGIxsoQiAbJEIxUUxAGyhC?=
	<yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailx.hitachi.co.jp ([133.145.228.49]:41191 "EHLO
	mailx.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756634AbXIUM0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 08:26:16 -0400
Received: from mlsv12.hitachi.co.jp (unknown [133.144.234.166])
	by mail4.hitachi.co.jp (Postfix) with ESMTP id 0A46533CD0
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 21:18:14 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set try to introduce memory usage accounting for
UDP(currently ipv4 only).

Currently, memory usage of UDP can be observed as the sam of
usage of tx_queue and rx_queue. But I believe that the system
wide accounting is usefull when heavy loaded condition.

In the next step, I would like to add memory usage quota
for UDP to avoid unlimited memory consumption problem
under DDOS attack.

This patch set is for 2.6.23-rc7.

Unfortunately, I don't have any NIC with UFO.
So this patch set is not tested with UFO supported
device.

I appreciate your comment/test/feedback.

Satoshi Oshima
