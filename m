From: James Chapman <jchapman@katalix.com>
Subject: L2TP support?
Date: Thu, 22 Mar 2007 16:09:09 +0000
Message-ID: <4602AA25.6020001@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33860 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934130AbXCVRD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 13:03:29 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=[192.168.1.10])
	by s36.avahost.net with esmtpa (Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1HUPqf-00086e-Qa
	for netdev@vger.kernel.org; Thu, 22 Mar 2007 11:09:11 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Is there interest in adding L2TP support?

I have a patch which could be submitted for review. The PPPoL2TP driver
presents a PPPoX socket to userspace pppd in the same way as the PPPoE
and PPPoATM drivers. The kernel handles all data traffic, while
userspace daemons do L2TP and PPP control message processing.

I posted an initial version of the patch in Sept 2004 (!). There was
some discussion about the use of PPPoX for L2TP in the following thread:

http://marc.info/?l=linux-netdev&m=109571479604766&w=2

In that thread, I was asked to improve the scalability of my solution by
avoiding the socket-per-session usage imposed by the PPPoX model. I
spent some time on this but was unable to come up with a better solution
than the original. Since then, the original PPPoX-based solution has
matured and is now use successfully by more than one L2TP protocol
implementation. My original work has been kept up to date with the
current kernel so could be submitted again if people want it. I didn't
want to repost it without revisiting the above thread first though... :)

Shall I post the patch?

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development




