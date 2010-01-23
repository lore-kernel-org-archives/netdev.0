From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] Fix IPv6 GSO type checks in Intel ethernet
 drivers
Date: Sat, 23 Jan 2010 02:02:28 -0800 (PST)
Message-ID: <20100123.020228.149341658.davem@davemloft.net>
References: <20100123100042.11995.20915.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sri@us.ibm.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40211
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752151Ab0AWKCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 05:02:17 -0500
In-Reply-To: <20100123100042.11995.20915.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 23 Jan 2010 02:00:43 -0800

> From: Sridhar Samudrala <sri@us.ibm.com>
> 
> Found this problem when testing IPv6 from a KVM guest to a remote
> host via e1000e device on the host.
> The following patch fixes the check for IPv6 GSO packet in Intel
> ethernet drivers to use skb_is_gso_v6(). SKB_GSO_DODGY is also set
> when packets are forwarded from a guest.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
