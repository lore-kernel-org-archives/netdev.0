From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: Work around 82571 completion timout on Pseries
 HW
Date: Thu, 17 May 2007 17:04:56 -0400
Message-ID: <464CC378.5070409@garzik.org>
References: <OFDD90D73E.30B0DB27-ON872572DE.004ED0BE-862572DE.005242EA@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	wendyx@linux.vnet.ibm.com
To: Wen Xiong <wenxiong@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41986 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754629AbXEQVFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 17:05:12 -0400
In-Reply-To: <OFDD90D73E.30B0DB27-ON872572DE.004ED0BE-862572DE.005242EA@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wen Xiong wrote:
> Here there are not hardware issue on both Intel or PPC.  The patch is to 
> work around a loop hold on early version of PCI SGI spec.  
> The later PCI Sgi have spec have corrected it.  We can just implement it 
> for PPC only.  Other vendor may have the same issue.


If it is not a PPC-specific issue, then we should not limit it to PPC.

	Jeff


