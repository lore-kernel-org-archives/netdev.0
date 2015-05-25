From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: TCP window auto-tuning sub-optimal in GRE tunnel
Date: Mon, 25 May 2015 11:42:04 -0400
Message-ID: <1432568524.32671.29.camel@jasiiieee.pacifera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.197]:59551 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732AbbEYPmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 11:42:10 -0400
Received: from [192.168.1.3] ([69.116.52.45]) by mrelay.perfora.net
 (mreueus003) with ESMTPSA (Nemesis) id 0MaKkg-1YhS1n1Xuy-00JpW5 for
 <netdev@vger.kernel.org>; Mon, 25 May 2015 17:42:07 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  I hope this is the correct list for this question.  We are
having serious problems on high BDP networks using GRE tunnels.  Our
traces show it to be a TCP Window problem.  When we test without GRE,
throughput is wire speed and traces show the window size to be 16MB
which is what we configured for r/wmem_max and tcp_r/wmem.  When we
switch to GRE, we see over a 90% drop in throughput and the TCP window
size seems to peak at around 500K.

What causes this and how can we get the GRE tunnels to use the max
window size? Thanks - John
