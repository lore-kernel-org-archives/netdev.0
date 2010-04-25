From: Dave Jones <davej@redhat.com>
Subject: 2.6.33.2 networking regression
Date: Sat, 24 Apr 2010 23:16:57 -0400
Message-ID: <20100425031656.GA27598@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45757 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150Ab0DYDRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Apr 2010 23:17:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Something odd happened when I upgraded my router
from 2.6.33.1 to .33.2.  Its internal NIC (a VIA Velocity)
stopped recieving packets.

dmesg was getting flooded with..

[  188.919957] via-velocity 0000:00:0e.0: BAR 0: set to [io  0xf800-0xf8ff] (PCI address [0xf800-0xf8ff]
[  188.920002] via-velocity 0000:00:0e.0: BAR 1: set to [mem 0xfdffe000-0xfdffe0ff] (PCI address [0xfdffe000-0xfdffe0ff]
[  203.913967] via-velocity 0000:00:0e.0: BAR 0: set to [io  0xf800-0xf8ff] (PCI address [0xf800-0xf8ff]
[  203.914181] via-velocity 0000:00:0e.0: BAR 1: set to [mem 0xfdffe000-0xfdffe0ff] (PCI address [0xfdffe000-0xfdffe0ff]

every so often for some reason.

rebooting back to .1, it works fine.

There don't appear to be any direct changes to via-velocity.c in the
diff, so I'm really confused. Any clues ? I'll bisect it, but it
probably won't be until Monday..

	Dave

