From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Wed, 26 Nov 2008 16:05:37 -0800
Message-ID: <200811261605.43099.jbarnes@virtuousgeek.org>
References: <492DD792.6080302@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail-02.bluehost.com ([69.89.21.12]:58836 "HELO
	outbound-mail-02.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752808AbYK0AFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 19:05:46 -0500
In-Reply-To: <492DD792.6080302@linux.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, November 26, 2008 3:11 pm Arjan van de Ven wrote:
> Rank 2: pci_create_slot (warning)
> 	Reported 603 times (639 total reports)
> 	BIOS provided duplicated slot names, the PCI layer blindly passes to sysfs
> 	This warning was last seen in version 2.6.27.5, and first seen in
> 2.6.27-rc7-git1. More info:
> http://www.kerneloops.org/searchweek.php?search=pci_create_slot

IIRC we fixed this one post-2.6.27.  I didn't send the patches back to -stable 
because they were a bit big, but if someone were sufficiently motiviated I'm 
sure the backport wouldn't be that hard...

Jesse
