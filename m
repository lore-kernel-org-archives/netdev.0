From: Tino Keitel <tino.keitel@gmx.de>
Subject: 2.6.24 regression: Wake On Lan in sky2 broken on Mac mini
Date: Mon, 28 Jan 2008 09:42:23 +0100
Message-ID: <20080128084222.GA5558@dose.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:55638 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792AbYA1JPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 04:15:38 -0500
Received: from dose.home.local (port-92-195-90-43.dynamic.qsc.de [92.195.90.43])
	by eazy.amigager.de (Postfix) with ESMTP id 203C0C8C1F5
	for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 09:42:16 +0100 (CET)
Received: from scorpion by dose.home.local with local (Exim 4.69)
	(envelope-from <tino.keitel@gmx.de>)
	id 1JJPZP-0001Ta-1x
	for netdev@vger.kernel.org; Mon, 28 Jan 2008 09:42:23 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

with 2.6.24-rc8, Wake On LAN doesn't work anymore as it used to with
2.6.23 on my Mac mini Core Duo. I saw that this was reported in
http://bugzilla.kernel.org/show_bug.cgi?id=9721 and on netdev a patch
for the sky2 driver was sent by Stephen Hemminger. This patch fixed WOL
for me after applying it to 2.6.24-rc8.

However, it seems as the patch never made it into the kernel. Instead,
the commit that was suspected to break WOL
(84cd2dfb04d23a961c5f537baa243fa54d0987ac) was reverted
(be63a21c9573fbf88106ff0f030da5974551257b).

Now I tried the 2.6.24 release and noticed that WOL is still broken.
I'll be happy to test any patches that can make it into 2.6.24.1.

Regards,
Tino
