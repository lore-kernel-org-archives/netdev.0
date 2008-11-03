From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: e100/netconsole: Failed to load firmware (Re: linux-next: Tree
	for November 3)
Date: Mon, 03 Nov 2008 16:09:27 +0000
Message-ID: <1225728567.745.13.camel@macbook.infradead.org>
References: <a4423d670811030425y1bdf93fcn829b7311e38731b9@mail.gmail.com>
	 <a4423d670811030749l53098b34i21af579c13ba112e@mail.gmail.com>
	 <1225727806.745.7.camel@macbook.infradead.org>
	 <20081103160057.GA12456@orion>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, jaswinder@infradead.org,
	linux-next@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56783 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754727AbYKCQJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 11:09:30 -0500
In-Reply-To: <20081103160057.GA12456@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-11-03 at 19:00 +0300, Alexander Beregalov wrote:
> # CONFIG_FIRMWARE_IN_KERNEL is not set
> CONFIG_EXTRA_FIRMWARE=""

OK, so you didn't include the E100 firmware in the kernel, so it only
actually manages to bring up the E100 after it's mounted the root file
system, not in time for the console?

If you set CONFIG_FIRMWARE_IN_KERNEL, does it work?

I think that's fairly much expected behaviour. I wonder if there's a way
we could make it slightly more intuitive though.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

