From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] Disable rp_filter for IPsec packets
Date: Sun, 10 Apr 2011 18:51:16 -0700 (PDT)
Message-ID: <20110410.185116.39190482.davem@davemloft.net>
References: <1302187911-20688-1-git-send-email-msmith@cbnco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: msmith@cbnco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51661
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752543Ab1DKBvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2011 21:51:52 -0400
In-Reply-To: <1302187911-20688-1-git-send-email-msmith@cbnco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Smith <msmith@cbnco.com>
Date: Thu,  7 Apr 2011 10:51:49 -0400

> The reverse path filter interferes with IPsec subnet-to-subnet tunnels,
> especially when the link to the IPsec peer is on an interface other than
> the one hosting the default route.
> 
> IPsec provides a much stronger anti-spoofing policy than rp_filter, so
> this patch disables the rp_filter for packets with a security path.
> 
> Patch is against net-next.

All applied, thanks Michael.
