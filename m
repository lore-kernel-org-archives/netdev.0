From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] IFix IPv6 GSO type checks in Intel
 ethernet drivers
Date: Tue, 19 Jan 2010 14:14:38 -0800 (PST)
Message-ID: <20100119.141438.266557246.davem@davemloft.net>
References: <1263934927.1635.24.camel@w-sridhar.beaverton.ibm.com>
	<alpine.WNT.2.00.1001191306450.5776@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, herbert@gondor.apana.org.au,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34518
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755079Ab0ASWO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 17:14:28 -0500
In-Reply-To: <alpine.WNT.2.00.1001191306450.5776@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Tue, 19 Jan 2010 13:11:00 -0800 (Pacific Standard Time)

> 
> 
> On Tue, 19 Jan 2010, Sridhar Samudrala wrote:
> 
>> Found this problem when testing IPv6 from a KVM guest to a remote
>> host via e1000e device on the host.
>> The following patch fixes the check for IPv6 GSO packet in Intel
>> ethernet drivers to use skb_is_gso_v6(). SKB_GSO_DODGY is also set
>> when packets are forwarded from a guest.
>> 
>> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com
> 
> Looks fine, thanks!  The current code in net-next and 2.6.32 both have 
> exactly the same condition in skb_is_gso_v6, so I'm not sure that this 
> patch alone will fix any issues, FYI.  If this patch is part of another 
> set or dependent upon another for the actual change in behavior mentioned 
> in the comment, I think it should be noted or sent in a series.
> 
> Ack-ed by: Jesse Brandeburg <jesse.brandeburg@intel.com>

Just FYI, I'm assuming I'll get this via Jeff eventually.
