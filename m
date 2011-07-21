From: Richard Kennedy <richard@rsk.demon.co.uk>
Subject: v3.0-rc* intermittent network failure: how to debug?
Date: Thu, 21 Jul 2011 14:49:54 +0100
Message-ID: <1311256194.2980.18.camel@castor.rsk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lon1-post-1.mail.demon.net ([195.173.77.148]:34844 "EHLO
	lon1-post-1.mail.demon.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750802Ab1GUNt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 09:49:56 -0400
Received: from rsk.demon.co.uk ([80.176.90.227] helo=[192.168.1.3])
	by lon1-post-1.mail.demon.net with esmtp (Exim 4.69)
	id 1QjtdS-0000p8-Yk
	for netdev@vger.kernel.org; Thu, 21 Jul 2011 13:49:54 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I keep seeing a total network failure on v3.0.0-rc* , it is highly
intermittent, anything from 1 hour to 12+, and I don't have a reliable
test case.
When it fails I lose all network comms, but there are no errors in the
system log, no hung tasks reported, nothing. But after it fails the
machine hangs during shutdown, it just never turns off. So I guess
something is getting stuck but I can't find it.

Can you suggest how to find out what going on? 
Or how collect more information as to what's failing?


I'm going to add a serial console and see if that helps.

this is on a x86_64, via_velocity currently running 3.0.0-rc7 latest.

all suggestions gratefully received

regards
Richard

