From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 v2 3/3] ixgbe: Look inside vlan when
 determining offload protocol.
Date: Fri, 12 Nov 2010 12:24:33 -0800 (PST)
Message-ID: <20101112.122433.115917799.davem@davemloft.net>
References: <1289519279-20641-1-git-send-email-jesse@nicira.com>
	<1289519279-20641-3-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hzheng@nicira.com,
	jeffrey.t.kirsher@intel.com, alexander.h.duyck@intel.com,
	jesse.brandeburg@intel.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47677
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932661Ab0KLUYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 15:24:09 -0500
In-Reply-To: <1289519279-20641-3-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Thu, 11 Nov 2010 15:47:59 -0800

> From: Hao Zheng <hzheng@nicira.com>
> 
> Currently the skb->protocol field is used to setup various
> offloading parameters on transmit for the correct protocol.
> However, if vlan offloading is disabled or otherwise not used,
> the protocol field will be ETH_P_8021Q, not the actual protocol.
> This will cause the offloading to be not performed correctly,
> even though the hardware is capable of looking inside vlan tags.
> Instead, look inside the header if necessary to determine the
> correct protocol type.
> 
> To some extent this fixes a regression from 2.6.36 because it
> was previously not possible to disable vlan offloading and this
> error case was not exposed.
> 
> Signed-off-by: Hao Zheng <hzheng@nicira.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Alex Duyck <alexander.h.duyck@intel.com>
> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
