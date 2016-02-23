From: sdrb@onet.eu
Subject: Variable download speed
Date: Tue, 23 Feb 2016 12:19:58 +0100 (CET)
Message-ID: <alpine.LNX.2.20.1602231216240.29937@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpo75.poczta.onet.pl ([141.105.16.25]:41487 "EHLO
	smtpo75.poczta.onet.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbcBWL26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 06:28:58 -0500
Received: from nowy9.kat.adbgroup.pl (unknown [91.230.58.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: sdrb@onet.eu)
	by smtp.poczta.onet.pl (Onet) with ESMTPSA id 3q8dFq2BvZzT789rD
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 12:19:58 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've got a problem with network on one of my embedded boards.
I'm testing download speed of 256MB file from my PC to embedded board 
through 1Gbit ethernet link using ftp.

The problem is that sometimes I achieve 25MB/s and sometimes it is only 
14MB/s. There are also situations where the transfer speed starts at 
14MB/s and after a few seconds achieves 25MB/s.
I've caught the second case with tcpdump and I noticed that when the speed 
is 14MB/s - the tcp window size is 534368 bytes and when the speed 
achieved 25MB/s the tcp window size is 933888.

My question is: what causes such dynamic change in the window size (while 
transferring data)?  Is it some kernel parameter wrong set or something 
like this?
Do I have any influence on such dynamic change in tcp window size?

sdrb
