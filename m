From: "Andrew Hall" <andrew.hall@bluereefnetworks.com>
Subject: re: [RFT] sky2: transmit complete alternative
Date: Thu, 31 Aug 2006 09:22:05 +1000
Message-ID: <050601c6cc8b$1cb4a8c0$5001010a@bluereef.local>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.mud.yahoo.com ([68.142.200.253]:49853 "HELO
	smtp105.biz.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1751629AbWH3XWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 19:22:09 -0400
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Has there been any updates on a fix for the sky2 tx timeout issues?

I have been tracking this problem for a while and consistently see this
issue when the interface is under heavy load. I'm using 2.6.17.11 but have
tried .15, .16, .17 and .18rcX all with the same issue - a large amount of
(HTTP generated test workload) traffic will cause the driver to stop 
responding, report an error (as below)
and the machine to "hang" for about 20 seconds. As others have mentioned, a
down/up of the interface will recover until it locks up again. The dmesg
output for me is usually something like:

sky2 eth1: tx timeout
sky2 eth1: transmit ring 397 .. 356 report=399 done 399
sky2 status report lost?

I have also tried the new transmit code that was supplied earlier in this
thread without improvement of this situation.

Any help appreciated.,

