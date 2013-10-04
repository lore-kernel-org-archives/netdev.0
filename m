From: "David Laight" <David.Laight@ACULAB.COM>
Subject: USB ethernet (smsc95xx) transmit timeout errors
Date: Fri, 4 Oct 2013 17:28:37 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7375@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39796 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754771Ab3JDQai convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 12:30:38 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16862-06 for <netdev@vger.kernel.org>;
 Fri,  4 Oct 2013 17:30:32 +0100 (BST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing some 'transmit timeout' errors from the smsc95xx driver.
I've found references to similar problems on the RPI, but no explicit
resolution.

Our systems are Intel i7 motherboards with the USB chip on a 'front panel'
board (together with three USB2 sockets) plugged into one on the
motherboard's USB3 sockets.
(The silicon has some kind of clever USB hub in it.)

Initial failures were with the 3.2 kernel from Ubuntu 12.04, but I've
updated one of the systems that failed to a 3.8 kernel and it still
fails.

Does this problem 'ring a bell' with anyone? and is it likely to have
been fixed in a more recent kernel?

Even with heavy traffic the systems might run for 24 hours before
failing - so proving a system is 'fixed' is difficult.

	David
