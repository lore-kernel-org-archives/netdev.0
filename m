From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: Warning/Oops report of the week of September 16th, 2008
Date: Tue, 16 Sep 2008 19:40:47 -0500
Message-ID: <20080916194047.0d23eb92@osprey.hogchain.net>
References: <20080916092206.6342c498@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, tglx@tglx.de, mingo@elte.hu,
	linux-acpi@vger.kernel.org, linux-scsi@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([204.127.217.105]:56061 "EHLO
	fmailhost05.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbYIQAkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 20:40:51 -0400
In-Reply-To: <20080916092206.6342c498@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Sep 2008 09:22:06 -0700
Arjan van de Ven <arjan@infradead.org> wrote:


> Not yet fixed issues
> ====================
> 
> Rank 1: dev_watchdog (warning)
> 	Reported 263 times (495 total reports)
> 	Network card timeout; this error is currently not specific
> enough, a patch is pending to get this reported per driver, with some
> luck this gets merged soon. This warning was last seen in version
> 2.6.27-rc6, and first seen in 2.6.26-rc3. More info:
> http://www.kerneloops.org/searchweek.php?search=dev_watchdog

Some of these are undoubtedly from the atl1 driver, and many of those
from that driver are probably from me personally as I've poked around
trying to isolate the cause.  I sent a patch yesterday to Alexey
Dobriyan (who's also been experiencing it) that seems to quash the
warnings, so hopefully we're near resolution.  On my own development
system I recently turned off kerneloops, so at least *my* contribution
to the list will diminish.  :)

Jay
