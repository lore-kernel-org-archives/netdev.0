From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: biosdevname v0.3.2
Date: Tue, 7 Dec 2010 12:19:10 -0600
Message-ID: <20101207181910.GA2643@auslistsprd01.us.dell.com>
References: <20101206140649.GA13628@auslistsprd01.us.dell.com> <1291745782.21627.6.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	"K, Narendra" <Narendra_K@Dell.com>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	Colin Watson <cjwatson@ubuntu.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:54421 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333Ab0LGSTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 13:19:15 -0500
Content-Disposition: inline
In-Reply-To: <1291745782.21627.6.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 07, 2010 at 06:16:22PM +0000, Ben Hutchings wrote:
> It appears that 'unknown slot' is treated as a specific slot and all
> devices with an unknown slot are given unique indices.  Perhaps this
> doesn't matter in the end, since no name is generated when the slot is
> unknown.

Yes on all counts.
 
> However, the 2 NIC ports do have their own indices (specified with the
> dev_id attribute) and it should be possible to distinguish slots by
> PCI/PCIe topology even though the name given won't correspond to any
> markings on the motherboard.

Tell me more about the dev_id attribute.  I'm happy to use it, but I
don't understand the rules around populating it.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
