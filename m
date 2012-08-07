From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?= <i@lri.fr>
Subject: Adding routes to another table: no such process
Date: Tue, 7 Aug 2012 16:13:06 +0200
Message-ID: <20120807141306.GB32655@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qult.net ([82.238.217.46]:53077 "EHLO qult.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077Ab2HGPAq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 11:00:46 -0400
Received: from zenon.in.qult.net ([192.168.128.3])
	by qult.net with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.76)
	(envelope-from <i@lri.fr>)
	id 1SykWx-0001sG-Qd
	for netdev@vger.kernel.org; Tue, 07 Aug 2012 16:13:07 +0200
Received: from ig by zenon.in.qult.net with local (Exim 4.76)
	(envelope-from <i@lri.fr>)
	id 1SykWw-0000I2-Kh
	for netdev@vger.kernel.org; Tue, 07 Aug 2012 16:13:06 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm having a hard time setting some routes on a router and can't find any
relevant information anywhere, so I resort to asking on this list.

The router has one interface, say eth0, with configured address 10.0.0.1/32.

Now I would like to do:

  ip rule add from 10.0.0.1 table 100
  ip route add 10.0.0.2/32 dev eth0 table 100
  ip route add 10.0.0.3/32 via 10.0.0.2 table 100

but I get

  RTNETLINK answers: No such process

on the third command.  It's just as though the kernel refused to use a
gateway for which there's no route in the main table.  Is this an actual
requirement for gateways?  I could find some examples around the web setting
routes with gateways in other tables than main, but they obviously don't work,
yielding the same error message.

Thanks for your help.

Ignacy

-- 
The groove will take you through times without money
much better than money will take you through times without groove.
