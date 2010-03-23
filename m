From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] be2net: fix unmap_single/page()
 called incorrectly in Tx compl processing
Date: Tue, 23 Mar 2010 13:23:34 -0700 (PDT)
Message-ID: <20100323.132334.32724810.davem@davemloft.net>
References: <20100323064134.GA3733@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38138
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752147Ab0CWUXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 16:23:11 -0400
In-Reply-To: <20100323064134.GA3733@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Tue, 23 Mar 2010 12:11:34 +0530

> The first wrb seen by tx compl processing does not have a dma handle in it.
> Currently, pci_unmap_single() is attempted on this wrb and pci_unmap_page() on the
> rest. So, pci_unmap_page() gets incorrectly called on the dma hdl of skb->data (that
> was mapped using map_single()). This patch fixes this issue.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
