From: Elimar Riesebieter <riesebie@lxtec.de>
Subject: kernel: TKIP: replay detected:
Date: Sun, 24 Sep 2006 12:40:53 +0200
Message-ID: <20060924104053.GA6645@frodo.home.lxtec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from h01.hostsharing.net ([212.42.230.152]:22946 "EHLO
	h01.hostsharing.net") by vger.kernel.org with ESMTP
	id S1751957AbWIXKlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 06:41:05 -0400
Received: from mail.home.lxtec.de (p549EF5B2.dip.t-dialin.net [84.158.245.178])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(No client certificate requested)
	by h01.hostsharing.net (Postfix) with ESMTP id 707FC161B665B
	for <netdev@vger.kernel.org>; Sun, 24 Sep 2006 12:28:55 +0200 (CEST)
Received: from localhost ([127.0.0.1])
	by mail.home.lxtec.de with esmtp (Exim 4.63 1 (LXTEC))
	id 1GRRPz-0006pW-Hq
	for <netdev@vger.kernel.org>; Sun, 24 Sep 2006 12:41:03 +0200
Received: from mail.home.lxtec.de ([127.0.0.1])
	by localhost (mail.home.lxtec.de [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id TQK1bZrxbltR for <netdev@vger.kernel.org>;
	Sun, 24 Sep 2006 12:40:55 +0200 (CEST)
Received: from frodo.home.lxtec.de ([192.168.200.202] ident=Debian-exim)
	by mail.home.lxtec.de with esmtps (Exim 4.63 1 (LXTEC))
	id 1GRRPr-0006pN-1z
	for <netdev@vger.kernel.org>; Sun, 24 Sep 2006 12:40:55 +0200
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I am running

zd1211rw 4-1:1.0: firmware version 4605
zd1211rw 4-1:1.0: zd1211 chip 6891:a727 v4330 high 00-14-7c RF2959_RF pa0 g---

IEEE 802.11b/g  ESSID:"BLO"  Nickname:"zd1211"
Mode:Managed  Frequency:2.462 GHz  Access Point: XX:XX:BB:LL:KK:00
Bit Rate:54 Mb/s
Link Quality=98/100  Signal level=91/100
Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
Tx excessive retries:0  Invalid misc:0   Missed beacon:0

in wpa/tkip mode.

My sylog is filled up with thousands of:
Sep 21 18:18:00 aragorn kernel: TKIP: replay detected: \
STA=XX:XX:BB:LL:KK:00 previous TSC 00000000BLAa received TSC 00000000BLAa
Sep 21 18:18:29 aragorn kernel: printk: 62 messages suppressed.

Driver is off kernel zd1211_2006-08-19.

Linux version 2.6.18, but has also on the rc ones.

How do I get rid of the syslog messages, which are trashing my vt's
at well?

Elimar

-- 
  Planung:
  Ersatz des Zufalls durch den Irrtum.
                                -unknown-
