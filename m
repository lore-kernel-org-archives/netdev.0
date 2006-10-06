From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] [TULIP] Check the return value from pci_set_mwi()
Date: Fri, 06 Oct 2006 15:15:15 -0400
Message-ID: <4526AB43.7030809@garzik.org>
References: <1160161519800-git-send-email-matthew@wil.cx> <11601615192857-git-send-email-matthew@wil.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Val Henson <val_henson@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:5800 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932450AbWJFTP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2006 15:15:26 -0400
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <11601615192857-git-send-email-matthew@wil.cx>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> Also, pci_set_mwi() will fail if the cache line
> size is 0, so we don't need to check that ourselves any more.

NAK, not true on all arches.  sparc64 at least presumes that the 
firmware DTRT with cacheline size, which hurts us now given this tulip patch

	Jeff


