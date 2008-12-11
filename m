From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: interface counters overflow (ppp)
Date: Thu, 11 Dec 2008 21:42:46 +0200
Message-ID: <200812112142.46202.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:41605 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755243AbYLKRr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 12:47:26 -0500
Received: from [192.168.4.94] (unknown [195.69.208.250])
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPSA id AB3C61A4AD8
	for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 19:35:50 +0200 (EET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there any plans to convert ppp counters to 64-bit values?
Sure backward compatible way. (new ioctl call?)

Current speeds on modern interfaces, even on 1Mbit DSL modem (PPPoE 
connection) will overflow pppd counters just in ~10 hours.

Current pppd implementation using SIOCGPPPSTATS ioctl, where is all fields 
related to byte counting is 32-bit.
