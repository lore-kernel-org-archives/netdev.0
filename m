From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vrf: set operstate and mtu at link create
Date: Thu, 02 Jun 2016 18:15:42 -0400 (EDT)
Message-ID: <20160602.181542.237830654292026292.davem@davemloft.net>
References: <1464840999-12763-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502AbcFBWQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 18:16:12 -0400
In-Reply-To: <1464840999-12763-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  1 Jun 2016 21:16:39 -0700

> The VRF device exists to define L3 domains and guide FIB lookups. As
> such its operstate is not relevant. Seeing 'state UNKNOWN' in the
> output of 'ip link show' can be confusing, so set operstate at link
> create.
> 
> Similarly, the MTU for a VRF device is not used; any fragmentation
> of the payload is done on the output path based on the real egress
> device. An MTU of 1500 on the VRF device while enslaved devices
> have a higher MTU can lead to confusion. Since the VRF MTU is not
> relevant set to 64k similar to what is done for loopback.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks.
