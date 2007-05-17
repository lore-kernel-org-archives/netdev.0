From: wendy xiong <wendyx@us.ibm.com>
Subject: Re: [PATCH] e1000: Work around 82571 completion timout on Pseries
	HW
Date: Thu, 17 May 2007 16:44:05 -0500
Message-ID: <1179438245.25390.8.camel@wendyx.austin.ibm.com>
References: <OFDD90D73E.30B0DB27-ON872572DE.004ED0BE-862572DE.005242EA@us.ibm.com>
	 <464CC378.5070409@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Wen Xiong <wenxiong@us.ibm.com>,
	Christoph Hellwig <hch@infradead.org>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	wendyx@linux.vnet.ibm.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:37326 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754892AbXEQVoI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 17:44:08 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4HLi738019917
	for <netdev@vger.kernel.org>; Thu, 17 May 2007 17:44:07 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4HLi7mN511720
	for <netdev@vger.kernel.org>; Thu, 17 May 2007 17:44:07 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4HLi60N024399
	for <netdev@vger.kernel.org>; Thu, 17 May 2007 17:44:07 -0400
In-Reply-To: <464CC378.5070409@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-05-17 at 17:04 -0400, Jeff Garzik wrote:
> Wen Xiong wrote:
> > Here there are not hardware issue on both Intel or PPC.  The patch is to 
> > work around a loop hold on early version of PCI SGI spec.  
> > The later PCI Sgi have spec have corrected it.  We can just implement it 
> > for PPC only.  Other vendor may have the same issue.
> 
> 
> If it is not a PPC-specific issue, then we should not limit it to PPC.
> 
> 	Jeff
> 
> 

Hi Jeff,

We have tested the patch on PowerPC CEC and IO drawers. We really want
to fix this for PPC. If you can accept for vendors, we are ok.

Thanks for your help!
wendy

