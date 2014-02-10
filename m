From: David Laight <David.Laight@ACULAB.COM>
Subject: SCTP and MSG_MORE
Date: Mon, 10 Feb 2014 10:11:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6BBC9E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55127 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752694AbaBJKM3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 05:12:29 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15787-02 for <netdev@vger.kernel.org>;
 Mon, 10 Feb 2014 10:12:19 +0000 (GMT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I hadn't realised that linux had a MSG_MORE exposed to userland...

The sctp stack could usefully use it to get multiple data chunks
into a single ethernet frame.

Currently it is very difficult to get more than one data chunk in
an ethernet frame which means that the ethernet packet rate is
much higher than it would be if the same traffic were sent using TCP.

I don't know enough about the SCTP code to even start looking for
where this might be implemented.  It might be almost trivial...

	David
