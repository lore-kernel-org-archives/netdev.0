From: Tino Keitel <tino.keitel@gmx.de>
Subject: Regression in 2.6.27-rc7: Wake On LAN with sky2 broken
Date: Wed, 24 Sep 2008 10:05:48 +0200
Message-ID: <20080924080546.GA21108@x61>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:52740 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbYIXIGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 04:06:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Wake On LAN from suspend to RAM doesn't work on my Mac mini Core Duo
with 2.6.27-rc7. I tested the same configuration with 2.6.26.3, and it
worked. With 2.6.27-rc7, the computer stays in suspended state. I can
still wake it up using the keyboard or power switch.

In my suspend script, I use the command "ethtool -s eth0 wol g" to
enable WOL even if it was disabled before.

Any hints what commit I should try to revert, before I start bisecting?

Regards,
Tino
