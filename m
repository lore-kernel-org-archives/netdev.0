From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 14:53:45 -0700 (PDT)
Message-ID: <20060928.145345.90823467.davem@davemloft.net>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net>
	<451C28E9.6040708@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, jgarzik@pobox.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47515
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161192AbWI1Vxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 17:53:42 -0400
To: auke-jan.h.kok@intel.com
In-Reply-To: <451C28E9.6040708@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Thu, 28 Sep 2006 12:56:25 -0700

> PHYS_ID pokes in hardware and makes it jump through hoops, in the case of some hardware 
> this could create a local DOS attack (e1000 suffers fromt his, probably more if not all) 
> where the NIC might stop receiving packets, or the big lock is help indefinately.
> 
> Not a good idea
> 
> The other ones are fine I think.

I've applied Stephen's patch with PHYS_ID removed from the
allowed list, thanks for the feedback.
