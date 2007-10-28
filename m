From: Chris Snook <csnook@redhat.com>
Subject: atl1 developers wanted
Date: Sun, 28 Oct 2007 02:33:28 -0400
Message-ID: <47242D38.1050804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jacliburn@bellsouth.net, greg@kroah.com
To: atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750900AbXJ1Gey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2007 02:34:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings, netdev!

	Since the Linux Driver Project apparently has a glut of talent, I figured I'd 
ask for a little help with an existing driver.  As some of you may know, Jay 
Cliburn and I have been working on atl1 since last summer, and we've gotten the 
driver merged and stable.  It does the basic things one expects a gigE driver to 
do, and it no longer does the things one expects a gigE driver to *not* do, but 
there are some hardware features that we don't support very well, or at all.

	If you have an atl1 board and want to get your hands dirty, we could use some 
help with the following:

Performance features:

TSO -- it works, but it's really slow, so we currently disable it by default
LRO -- would be nice to have
NAPI -- would be nice to have
configurable interrupt coalescing -- we're not currently taking advantage of this

feature testing:

jumbo frames -- last I checked, I could open connections with large MTU, but 
we've done very little validation, benchmarking, or optimization

IPv6 -- seems to work, but the hardware doesn't support offloading for IPv6 
traffic, so we need to know about the performance to prioritize work on the 
aforementioned performance features

other:

make WoLAN work reliably

	-- Chris
