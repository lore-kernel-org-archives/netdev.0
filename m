From: maximilian attems <max@stro.at>
Subject: 2.6.24-rc8 ppp regression
Date: Wed, 23 Jan 2008 10:35:09 +0100
Message-ID: <20080123093509.GA4718@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:44698 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbYAWJfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 04:35:15 -0500
Received: from dual (sputnik.itp.tuwien.ac.at [128.131.48.177])
	by baikonur.stro.at (Postfix) with ESMTP id 9481E5C001
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 10:34:20 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


when killing a wvdial usb modem session:

Jan 22 23:23:03 dual pppd[7941]: Terminating on signal 15
Jan 22 23:23:03 dual pppd[7941]: Connect time 92.2 minutes.
Jan 22 23:23:03 dual pppd[7941]: Sent 1322316 bytes, received 8587156 bytes.
Jan 22 23:23:03 dual pppd[7941]: Connection terminated.
Jan 22 23:23:05 dual kernel: usb 3-2: USB disconnect, address 5
Jan 22 23:23:05 dual kernel: option 3-2:1.0: device disconnected
Jan 22 23:23:05 dual kernel: option1 ttyUSB1: GSM modem (1-port) converter now disconnected from ttyUSB1
Jan 22 23:23:05 dual kernel: option 3-2:1.1: device disconnected
Jan 22 23:23:13 dual kernel: unregister_netdevice: waiting for ppp0 to become free. Usage count = 1
Jan 22 23:23:44 dual last message repeated 3 times
Jan 22 23:23:54 dual kernel: unregister_netdevice: waiting for ppp0 to become free. Usage count = 1


2.6.24-rc7 works fine, not yet bisected, will do later in the evening.

-- 
maks
