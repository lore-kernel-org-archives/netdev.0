From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/2] [PCI] Check that MWI bit really did get set
Date: Mon, 16 Oct 2006 11:58:15 +0100
Message-ID: <1160996295.24237.15.camel@localhost.localdomain>
References: <1160161519800-git-send-email-matthew@wil.cx>
	 <20061015191631.DE49D19FEC8@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
	 <20061015123432.4c6b7f15.akpm@osdl.org>
	 <200610151545.59477.david-b@pacbell.net>
	 <20061015161834.f96a0761.akpm@osdl.org>
	 <1160956960.5732.99.camel@localhost.localdomain>
	 <20061015164402.f9b8b4d2.akpm@osdl.org>
	 <17714.54766.390707.532248@cargo.ozlabs.ibm.com>
	 <20061015181044.ec414e4f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>,
	David Brownell <david-b@pacbell.net>, matthew@wil.cx,
	val_henson@linux.intel.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org,
	gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:54234 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1030348AbWJPKbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 06:31:44 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061015181044.ec414e4f.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Sul, 2006-10-15 am 18:10 -0700, ysgrifennodd Andrew Morton:
> Question is, should pci_set_mwi() ever return -EFOO?  I guess it should, in
> the case where setting the line size didn't work out.

It does no harm, no driver will ever check anything but 0 v !0 because
the handling is no different in either case.

