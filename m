From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] [PCI] Check that MWI bit really did get set
Date: Fri, 06 Oct 2006 15:16:36 -0400
Message-ID: <4526AB94.7060200@garzik.org>
References: <1160161519800-git-send-email-matthew@wil.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Val Henson <val_henson@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:12200 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1422680AbWJFTQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2006 15:16:50 -0400
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <1160161519800-git-send-email-matthew@wil.cx>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> Since some devices may not implement the MWI bit, we should check that
> the write did set it and return an error if it didn't.
> 
> Signed-off-by: Matthew Wilcox <matthew@wil.cx>

ACK, though (as it seems you are doing) you should audit pci_set_mwi() 
users to make sure behavior matches up with this implementation

	Jeff



