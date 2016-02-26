From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] net: l3mdev: Fix source address for
 unnumbered deployments
Date: Fri, 26 Feb 2016 14:24:15 -0500 (EST)
Message-ID: <20160226.142415.547838324109543423.davem@davemloft.net>
References: <1456343223-17622-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbcBZTYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 14:24:19 -0500
In-Reply-To: <1456343223-17622-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 24 Feb 2016 11:47:01 -0800

> David Lamparter noted a use case where the source address selection fails
> to pick an address from a VRF interface - unnumbered interfaces. The use
> case has the VRF device as the VRF local loopback with addresses and
> interfaces enslaved without an address themselves. e.g,
 ...
> ping to the 10.2.2.2 through the L3 domain:
 ...
> picks up the wrong address -- the one from 'lo' not vrf0. And from tcpdump:
>     12:57:29.449128 IP 9.9.9.9 > 10.2.2.2: ICMP echo request, id 2491, seq 1, length 64
> 
> This patch series changes address selection to only consider devices in
> the same L3 domain and to use the VRF device as the L3 domains loopback.
 ...

Series applied, thanks David.
