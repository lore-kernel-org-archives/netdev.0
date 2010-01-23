From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbevf: Fix IPv6 GSO type checks
Date: Sat, 23 Jan 2010 02:06:33 -0800 (PST)
Message-ID: <20100123.020633.99668719.davem@davemloft.net>
References: <20100123100140.12032.63705.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sri@us.ibm.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752351Ab0AWKGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 05:06:22 -0500
In-Reply-To: <20100123100140.12032.63705.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 23 Jan 2010 02:02:22 -0800

> Based on patch from Sridhar Samudrala
> 
> The following patch fixes the check for IPv6 GSO packet in ixgbevf
> driver to use skb_is_gso_v6(). SKB_GSO_DODGY is also set
> when packets are forwarded from a guest.
> 
> CC: Sridhar Samudrala <sri@us.ibm.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
