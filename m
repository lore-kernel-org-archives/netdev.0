From: Gavin McCullagh <gavin.mccullagh@nuim.ie>
Subject: fixing opt-ack DoS against TCP stack
Date: Tue, 09 Jan 2007 14:24:38 +0000
Message-ID: <20070109142437.GF31536@nuim.ie>
Reply-To: Gavin McCullagh <gavin.mccullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: Douglas Leith <doug.leith@nuim.ie>,
	David Malone <David.Malone@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nuim.ie ([149.157.1.19]:64935 "EHLO LARCH.MAY.IE"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932335AbXAIUF4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 15:05:56 -0500
Received: from retina-bcl.hamilton.local ([149.157.192.252])
 by NUIM.IE (PMDF V6.2-X17 #30789) with ESMTPA id <01MBQ8LEPEBA00V8K9@NUIM.IE>
 for netdev@vger.kernel.org; Tue, 09 Jan 2007 14:25:01 +0000 (GMT)
To: netdev@vger.kernel.org
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

recently, a few of us came up with a novel (or so we thought) DoS attack
against TCP.  We spent some time implementing and testing it and found it
to work worryingly well.

It turns out that we are not the first to come across this attack.  Rob
Sherwood and colleagues in Maryland were a year or two ahead of us.  They
have published a paper entitled "Misbehaving TCP Receivers Can Cause
Internet-Wide Congestion Collapse".

	http://www.cs.umd.edu/~capveg/optack/optack-ccs05.pdf
	http://www.cs.umd.edu/~capveg/
	http://www.kb.cert.org/vuls/id/102014

Linux appears not to have implemented any fix for this vulnerability,
although Rob Sherwood wrote a patch against 2.4.24.

	http://www.cs.umd.edu/~capveg/optack/optack.patch

There seems to be a brief mention of it on the fedora-security list but I
can't find much discussion of it in linux circles otherwise.

	http://www.spinics.net/linux/fedora/fedora-security/msg00426.html
	http://www.securityfocus.com/bid/15468/

Is there some reason that this fix was not accepted or has this just
slipped under people's radars?  Should some fix not be implemented?  The
issue seems even more severe with the larger buffer sizes now in use.

Gavin

