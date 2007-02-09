From: Pavel Roskin <proski@gnu.org>
Subject: Re: Hermes PCI broken on 2.6.20?
Date: Fri, 09 Feb 2007 00:29:51 -0500
Message-ID: <1170998991.4764.4.camel@dv>
References: <20070209012819.GA23490@plexity.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
To: dsaxena@plexity.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:60471 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946119AbXBIF34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 00:29:56 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.60)
	(envelope-from <proski@gnu.org>)
	id 1HFOJP-0007iG-9g
	for netdev@vger.kernel.org; Fri, 09 Feb 2007 00:28:43 -0500
In-Reply-To: <20070209012819.GA23490@plexity.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On Thu, 2007-02-08 at 17:28 -0800, Deepak Saxena wrote: 
> Running both 2.6.20 and 2.6.18, the hermes PCI driver (CONFIG_HERMES_PCI)
> gives the following errors. Card is a revision 1 chipset (Dev ID 3873).
> Note that when iwconfig is run a few times in a row, the error messages
> go away but they might just be getting ratelimited. Anyone else seen
> this?
> 
> root@10.40.20.173:~# iwconfig
> eth0      no wirhermes @ c8810000: Card removed while waiting for command
> 0x0021 completion.
> eless extensionshermes @ c8810000: Card removed while issuing command
> 0x0021.

I don't see any problems with orinoco_pci in Linux 2.6.20.  It looks
more like a hardware problem or some very old firmware.

Just to exclude possible problems with the driver that I cannot
reproduce, please try hostap_pci.  It supports all devices supported by
orinoco_pci.

You may want to send further replies to
orinoco-devel@lists.sourceforge.net where it would be seen by those
actually using the driver.

-- 
Regards,
Pavel Roskin

