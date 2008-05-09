From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/16] myri10ge updates
Date: Fri, 09 May 2008 02:15:31 +0200
Message-ID: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1813 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755306AbYEIAqJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:46:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jeff,

myri10ge has not been updated for a while, so here's a huge pile of
patches to fix a couple minor things and add multislices and DCA support:

01 - update firmware headers
02 - fix module parameter descriptions
03 - increase and fix handoff timeout
04 - properly align scratch buffers
05 - don't warn on rx page allocation failure
06 - report FIBER in ethtool for XFP based NIC
07 - add barrier in myri10ge_send_cmd
08 - trivial formatting fix
09 - fix potential infinite loop in enable_ecrc
10 - move data structures into a single slice
11 - cleanup retrieving of firmware capabilities
12 - fix the number of interrupt slots
13 - add routines for multislices
14 - add multislices support
15 - add Direct Cache Access support
16 - update driver version

01-09 are trivial and should easily go into 2.6.26. The other ones are
much more intrusive, so I'll understand if they have to wait until
2.6.27. Just make sure you don't pickup anything out of order since
there are big dependencies among the last ones.

Note that 10-14 are actually mostly the same thing. But a single patch
for all the multislices support would have been unreviewable, so I tried
to split it into independent pieces.

thanks,
Brice

