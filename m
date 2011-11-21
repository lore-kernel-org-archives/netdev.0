From: "Eugene B. Berdnikov" <bd4@protva.ru>
Subject: Path MTU discovery and tuntap
Date: Tue, 22 Nov 2011 00:33:59 +0400
Message-ID: <20111121203359.GE2640@sie.protva.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tornado.rdtex.ru ([80.252.139.3]:55552 "EHLO tornado.rdtex.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751966Ab1KUVWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 16:22:14 -0500
Received: from localhost ([127.0.0.1]:58836)
	by tornado.rdtex.ru with esmtp (Exim 4.69)
	(envelope-from <bd4@protva.ru>)
	id 1RSaZ0-0005wF-KF size 1565
	for netdev@vger.kernel.org; Tue, 22 Nov 2011 00:34:02 +0400
Received: from tornado.rdtex.ru ([127.0.0.1])
	by localhost (tornado.rdtex.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Z6+wkzBYuhfO for <netdev@vger.kernel.org>;
	Tue, 22 Nov 2011 00:34:00 +0400 (MSK)
Received: from [192.168.27.13] (port=45752 helo=sie.protva.ru)
	by tornado.rdtex.ru with esmtp (Exim 4.69)
	(envelope-from <bd4@protva.ru>)
	id 1RSaYy-0005w4-64 size 1063
	for netdev@vger.kernel.org; Tue, 22 Nov 2011 00:34:00 +0400
Received: from berd by sie.protva.ru with local (Exim 4.77)
	(envelope-from <bd4@protva.ru>)
	id 1RSaYx-0001EK-3a
	for netdev@vger.kernel.org; Tue, 22 Nov 2011 00:33:59 +0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Hi folks.

 I have two routers running a tun-based tunneling applications.
 Both forward packets from eth (mtu=1500) to tun (mtu=1300),
 emitting icmp[frag-need] if DF=1 and packet size > 1300. That's nice.
 But one router simply drops oversized packet after icmp emittion,
 and other one delivers oversized packet to application's tun.
 The difference is that 1st router runs 2.6.30 (it drops packet) and
 the 2nd runs 3.0.0 (delivers to app). Kernels are from Debian/testing.

 The question is: was it an intentional change or some bug?
-- 
 Eugene Berdnikov
