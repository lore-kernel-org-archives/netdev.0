From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: vlan: enforce no pvid flag in vlan
 ranges
Date: Mon, 12 Oct 2015 19:59:33 -0700 (PDT)
Message-ID: <20151012.195933.1620669188577531568.davem@davemloft.net>
References: <20151011071208.GA2188@nanopsycho.orion>
	<1444560596-7140-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	eladr@mellanox.com, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932092AbbJMCne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 22:43:34 -0400
In-Reply-To: <1444560596-7140-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Sun, 11 Oct 2015 12:49:56 +0200

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Currently it's possible for someone to send a vlan range to the kernel
> with the pvid flag set which will result in the pvid bouncing from a
> vlan to vlan and isn't correct, it also introduces problems for hardware
> where it doesn't make sense having more than 1 pvid. iproute2 already
> enforces this, so let's enforce it on kernel-side as well.
> 
> Reported-by: Elad Raz <eladr@mellanox.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
