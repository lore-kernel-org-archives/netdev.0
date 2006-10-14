From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH 1/2] [PCI] Check that MWI bit really did get set
Date: Sat, 14 Oct 2006 08:02:49 -0600
Message-ID: <20061014140249.GL11633@parisc-linux.org>
References: <1160161519800-git-send-email-matthew@wil.cx> <20061013214135.8fbc9f04.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Val Henson <val_henson@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:61419 "EHLO
	mail.parisc-linux.org") by vger.kernel.org with ESMTP
	id S1422643AbWJNOCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Oct 2006 10:02:50 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061013214135.8fbc9f04.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 13, 2006 at 09:41:35PM -0700, Andrew Morton wrote:
> Bisection shows that this patch
> (pci-check-that-mwi-bit-really-did-get-set.patch in Greg's PCI tree) breaks
> suspend-to-disk on my Vaio.  It writes the suspend image and gets to the
> point where it's supposed to power down, but doesn't.

How odd.  What driver is calling pci_set_mwi() on the suspend path?
What drivers do you have loaded on the Vaio?
