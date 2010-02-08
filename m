From: Daniel Mack <daniel@caiaq.de>
Subject: Re: smsc911x suspend/resume
Date: Mon, 8 Feb 2010 11:11:23 +0100
Message-ID: <20100208101123.GW28972@buzzloop.caiaq.de>
References: <4B6FDC83.9090205@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org,
	LAKML <linux-arm-kernel@lists.infradead.org>
To: Mike Rapoport <mike@compulab.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:40828 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754748Ab0BHKL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 05:11:28 -0500
Content-Disposition: inline
In-Reply-To: <4B6FDC83.9090205@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 08, 2010 at 11:42:27AM +0200, Mike Rapoport wrote:
> I'm trying to make suspend/resume work on OMAP3-based system and I'm
> encountering issues with resume of SMSC 9220 chip.
> After resume the interface is unusable unless I do 'ifconfig eth0 down'
> and 'ifconfig eth0 up'.
> I would expect that 'ping <some host>' would work right after resume
> without need to bring the interface down and up, but probably I miss
> something.
> Any help would be appreciated.

What happens to your supply voltages when going to suspend? When I
implemented the code for the smsc driver, I could only test scenarios
where AVDD remains stable during suspend. So the driver might need some
tweaks if that assumption is not true in your case. The SMSC datasheet
is quite comprehensive about this topic IIRC.

Also have a look at the Raumfeld device patches which use exactly this
chip and which can suspend and resume just fine. You'll need to check
out Eric's devel branch for that.

Daniel

