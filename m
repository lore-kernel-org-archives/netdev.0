From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/2] [PCI] Check that MWI bit really did get set
Date: Mon, 16 Oct 2006 01:02:40 +0100
Message-ID: <1160956960.5732.99.camel@localhost.localdomain>
References: <1160161519800-git-send-email-matthew@wil.cx>
	 <20061015191631.DE49D19FEC8@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
	 <20061015123432.4c6b7f15.akpm@osdl.org>
	 <200610151545.59477.david-b@pacbell.net>
	 <20061015161834.f96a0761.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>, matthew@wil.cx,
	val_henson@linux.intel.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org,
	gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:36538 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP id S932175AbWJOXgj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Oct 2006 19:36:39 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061015161834.f96a0761.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Sul, 2006-10-15 am 16:18 -0700, ysgrifennodd Andrew Morton:
> No.  If pci_set_mwi() detects an unexpected error then the driver should
> take some action: report it, recover from it, fail to load, etc.  If the
> driver fails to do any of this then it's a buggy driver.

Wrong and there are several drivers in the kernel that are proof of
this.

> You, the driver author _do not know_ what pci_set_mwi() does at present, on
> all platforms, nor do you know what it does in the future.  For you the

You don't care. It isn't an error for set_mwi to fail. In fact the only
reason set_mwi even needs to bother with a return code is that some
chips want you to set other config private to the device if it is
available and active.

Alan

