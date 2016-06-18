From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: vrf: Fix ipv6 source address
 selection
Date: Fri, 17 Jun 2016 21:26:56 -0700 (PDT)
Message-ID: <20160617.212656.1193508271619637864.davem@davemloft.net>
References: <1466119466-3144-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56729 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbcFRE1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 00:27:00 -0400
In-Reply-To: <1466119466-3144-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 16 Jun 2016 16:24:23 -0700

> IPv6 address selection is currently messed up for several use cases such
> as unnumbered deployments with global addresses on the VRF device and none
> on the enslaved devices.
> 
> Update the source address selection to consider the real output route as
> opposed to the VRF route that sends packets to the VRF device first (ie.,
> implement get_saddr6 similar to the IPv4 method) and update the IPv6
> address selection to consider L3 domains and preference for addresses on
> the VRF device).

Series applied.
