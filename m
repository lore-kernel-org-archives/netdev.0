From: Greg KH <greg@kroah.com>
Subject: Re: Oops/Warning report for the week of December 3rd, 2008
Date: Wed, 3 Dec 2008 20:35:33 -0800
Message-ID: <20081204043533.GE18027@kroah.com>
References: <20081203184652.0601b86b@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	linux-pci@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org,
	tytso@mit.edu, akpm@linux-foundation.org, alan@redhat.com,
	airlied@redhat.com
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:51875 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755315AbYLDEsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 23:48:25 -0500
Content-Disposition: inline
In-Reply-To: <20081203184652.0601b86b@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 03, 2008 at 06:46:52PM -0800, Arjan van de Ven wrote:
> Rank 1: pci_create_slot (warning)
> 	Reported 1224 times (1662 total reports)
> 	BIOS provided duplicated slot names, the PCI layer blindly passes to sysfs
> 	This warning was last seen in version 2.6.27.5, and first seen in 2.6.27-rc7-git1.
> 	More info: http://www.kerneloops.org/searchweek.php?search=pci_create_slot

This will be fixed in 2.6.27.8, so it should go away soon.

> Rank 5: VBoxDrvLinuxIOCtl (warning)
> 	Reported 756 times (2332 total reports)
> 	[external] bug in the VirtualBox drivers
> 	This warning was last seen in version 2.6.28-rc3, and first seen in 2.6.25.11.
> 	More info: http://www.kerneloops.org/searchweek.php?search=VBoxDrvLinuxIOCtl

Does anyone have a link to the virtualbox linux kernel drivers?  I can't
seem to find them poking around on their site.  All I found were some
strange C++ files that couldn't possibly be the kernel code...

> Rank 14: sysfs_add_one (oops)
> 	Reported 195 times (213 total reports)
> 	Duplicate sysfs registration; mostly in USB audio
> 	This oops was last seen in version 2.6.27.5, and first seen in 2.6.25.
> 	More info: http://www.kerneloops.org/searchweek.php?search=sysfs_add_one

Should be resolved in 2.6.27.7, interesting that no one reported it in
.6, perhaps no distro did a release with that kernel version.

thanks,

greg k-h
