From: Michael Buesch <mb@bu3sch.de>
Subject: Re: bcm43xx: "transmit timed out" and apparent hang with "preemptible periodic work" patches
Date: Mon, 26 Jun 2006 14:43:47 +0200
Message-ID: <200606261443.47341.mb@bu3sch.de>
References: <87ac80ps5o.fsf@briny.internal.ondioline.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:42373
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751115AbWFZMop
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 08:44:45 -0400
To: Paul Collins <paul@briny.ondioline.org>
In-Reply-To: <87ac80ps5o.fsf@briny.internal.ondioline.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 26 June 2006 04:28, Paul Collins wrote:
> With the bcm43xx periodic work patches that recently made it into
> Linus's tree, my PowerBook does not survive running overnight.
> 
> Yesterday I reverted
> 
> 91769e7dd9cef7988dc4280f74ed168351beb5b8 [PATCH] bcm43xx: preemptible periodic work
> 78ff56a06edc3407996173daf63e48f6b90c7062 [PATCH] bcm43xx: redesign locking
> 
> and it was still alive this morning.
> 
> The following is logged, but that may not be all since the screen was
> turned off and kern.log was marked for no-fsync.
> 
> Jun 24 06:53:41 briny kernel: NETDEV WATCHDOG: eth1: transmit timed out
> Jun 24 06:53:41 briny kernel: bcm43xx: Controller RESET (TX timeout) ...
> Jun 24 06:53:41 briny kernel: bcm43xx: Chip ID 0x4306, rev 0x3
> Jun 24 06:53:41 briny kernel: bcm43xx: Number of cores: 5
> Jun 24 06:53:41 briny kernel: bcm43xx: Core 0: ID 0x800, rev 0x4, vendor 0x4243, enabled
> Jun 24 06:53:41 briny kernel: bcm43xx: Core 1: ID 0x812, rev 0x5, vendor 0x4243, disabled
> Jun 24 06:53:41 briny kernel: bcm43xx: Core 2: ID 0x80d, rev 0x2, vendor 0x4243, enabled
> Jun 24 06:53:41 briny kernel: bcm43xx: Core 3: ID 0x807, rev 0x2, vendor 0x4243, disabled
> Jun 24 06:53:41 briny kernel: bcm43xx: Core 4: ID 0x804, rev 0x9, vendor 0x4243, enabled
> Jun 24 06:53:41 briny kernel: bcm43xx: PHY connected
> Jun 24 06:53:41 briny kernel: bcm43xx: Detected PHY: Version: 2, Type 2, Revision 2
> Jun 24 06:53:41 briny kernel: bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
> Jun 24 06:53:41 briny kernel: bcm43xx: Radio turned off
> Jun 24 06:53:41 briny kernel: bcm43xx: Radio turned off
> Jun 24 06:53:41 briny kernel: bcm43xx: Controller restarted

Try to get more logs.
I suggest to do a netconsole for logging.

-- 
Greetings Michael.
