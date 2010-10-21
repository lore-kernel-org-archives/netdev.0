From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: Allow tagged VLAN packets to flow through
 VETH devices.
Date: Thu, 21 Oct 2010 04:07:17 -0700 (PDT)
Message-ID: <20101021.040717.241928814.davem@davemloft.net>
References: <1287167705-28583-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60697
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757352Ab0JULGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:06:55 -0400
In-Reply-To: <1287167705-28583-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 15 Oct 2010 11:35:05 -0700

> When there are VLANs on a VETH device, the packets being transmitted
> through the VETH device may be 4 bytes bigger than MTU.  A check
> in dev_forward_skb did not take this into account and so dropped
> these packets.
> 
> This patch is needed at least as far back as 2.6.34.7 and should
> be considered for -stable.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Applied, although a check of the vlan-capable netdev flag
might be appropriate to add.
