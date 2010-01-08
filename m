From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2: Flush the register writes which setup
 the MSI-X table
Date: Fri, 08 Jan 2010 00:51:31 -0800 (PST)
Message-ID: <20100108.005131.111707641.davem@davemloft.net>
References: <1262822843-14700-1-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kalyanc@vmware.com, mchan@broadcom.com
To: benli@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37078
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750709Ab0AHIvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:51:23 -0500
In-Reply-To: <1262822843-14700-1-git-send-email-benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Benjamin Li" <benli@broadcom.com>
Date: Wed, 6 Jan 2010 16:07:23 -0800

> The MSI-X table size needs to be properly set before pci_enable_msix()
> is called.  But on certain machines, the writes are delayed and the
> MSI-X table size is incorrectly read.  By reading the
> BNX2_PCI_MSIX_CONTROL register, the writes are flushed and now
> ensure that the MSI-X table is set correctly before MSI-X
> is enable on the device.
> 
> This patch was originally diagnosed and authored by
> Kalyan Ram Chintalapati <kalyanc@vmware.com>.
> 
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Kalyan Ram Chintalapati <kalyanc@vmware.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
