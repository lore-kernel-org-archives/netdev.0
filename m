From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5 v2] net: Add saddr op to l3mdev and vrf
Date: Wed, 07 Oct 2015 04:28:40 -0700 (PDT)
Message-ID: <20151007.042840.43030149731109082.davem@davemloft.net>
References: <1444060287-11024-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbbJGLMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 07:12:55 -0400
In-Reply-To: <1444060287-11024-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon,  5 Oct 2015 08:51:22 -0700

> First 2 patches are re-sends of patches that got lost in the ethosphere
> Tuesday; they were part of the first round of l3mdev conversions.
> Next 3 handle the source address lookup for raw and datagram sockets
> bound to a VRF device.
> 
> The conversion to the get_saddr op also fixes locally originated TCP
> packets showing up at the VRF device. The use of the FLOWI_FLAG_L3MDEV_SRC
> flag in ip_route_connect_init was causing locally generated packets
> to skip the VRF device.
> 
> v2
> - rebased to top of net-next per device delete fix and hash based
>   multipath patches

Series applied, thanks.
