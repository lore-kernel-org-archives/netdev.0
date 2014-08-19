From: David Laight <David.Laight@ACULAB.COM>
Subject: Lost ping responses
Date: Tue, 19 Aug 2014 10:28:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1747B1C0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38293 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750779AbaHSK3p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 06:29:45 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13223-04 for <netdev@vger.kernel.org>;
 Tue, 19 Aug 2014 11:29:34 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of some other testing I've been saturating a point to point
100M ethernet links with 3 flood pings of 60k messages.
The response time is then 17-20ms, and there are no missing responses.
If I also do a 'normal' ping, that one sees a 25% packet loss.

ifconfig doesn't show any errors, and the tx and rx counts match
between the systems. All the packets seem to get lost on the system
that is responding to the ping requests.

Any ideas how to find out where the discards are happening?
It might just be somewhere that would affect other traffic flows.

Both systems are Intel i7 - so no shortage of cpu power or memory.
The pings are being sent from a PCIe e1000e card, and reflected
by a USB smsx95xx one.
(I was just loading the USB wire, nothing odd happened during the test.)

	David
