From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] xen-netback: add gso_segs calculation
Date: Thu, 19 Dec 2013 15:12:42 -0500 (EST)
Message-ID: <20131219.151242.1564799045825215690.davem@davemloft.net>
References: <1387280675-10295-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	wei.liu2@citrix.com, ian.campbell@citrix.com,
	david.vrabel@citrix.com, eric.dumazet@gmail.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655Ab3LSUMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 15:12:45 -0500
In-Reply-To: <1387280675-10295-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Tue, 17 Dec 2013 11:44:35 +0000

> netback already has code which parses IPv4 and v6 headers to set up checksum
> offsets and these are always applied to GSO packets being sent from
> frontends. It's therefore suboptimal that GSOs are being marked
> SKB_GSO_DODGY to defer the gso_segs calculation when netback already has all
> necessary information to hand to do the calculation. This patch adds that
> calculation.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

Applied, thanks.
