From: Chris Snook <csnook@redhat.com>
Subject: [RFC] introducing the Atheros L2 Fast Ethernet driver
Date: Tue, 04 Dec 2007 17:24:29 -0500
Message-ID: <4755D39D.30005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: synrg@debian.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41247 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000AbXLDWYf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 17:24:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey folks --

	I've begun cleaning up the atl2 vendor driver for merging.  It's very similar 
to the atl1 driver, and needs a lot of the same work, though I have already 
fixed the 64-bit DMA data corrupter that atl1 users remember so fondly.  Right 
now this is very raw, and there is a large amount of cosmetic work to do to make 
it more maintainable, but it should generally work, at least as well as the 
vendor driver does.

	While this is in pre-submission cleanup mode, the latest standalone source 
tarball and patch (currently against 2.6.23) will be available here:

http://people.redhat.com/csnook/atl2/

	If you have atl2 hardware, please give this a spin.  I plan to submit the 
driver for merging some time in the next month or so.  Questions, comments, 
patches welcome.

	-- Chris
