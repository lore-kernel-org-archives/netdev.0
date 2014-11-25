From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 0/2] Fix outer UDP checksums for IPv6 VXLAN tunnels
Date: Tue, 25 Nov 2014 14:13:05 -0500 (EST)
Message-ID: <20141125.141305.1951284300777976974.davem@davemloft.net>
References: <20141125035808.13612.52556.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbaKYTNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:13:08 -0500
In-Reply-To: <20141125035808.13612.52556.stgit@ahduyck-workstation.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: alexander.duyck@gmail.com
Date: Mon, 24 Nov 2014 20:08:25 -0800

> In testing against an older kernel I found a couple issues in the IPv6
> VXLAN tunnel checksum logic for the outer UDP checksum.
> 
> First the default transitioned from using an outer checksum to not using
> one.  Second, sometime after that the checksum inputs were changed
> resulting the checksum not being correct if it were computed.
> 
> These two issues prevented a ping from the newer kernel to the older one.
> With these two changes applied I verified I was able to send traffic over
> the VXLAN tunnel to a link partner on an older kernel.
> 
> The boolean flip fix can be submitted for 3.17 stable as well since the
> patch that introduced the issue was included in that kernel.

Series applied and queued up for -stable, thanks.
