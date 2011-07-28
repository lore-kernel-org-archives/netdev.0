From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: add IFF_SKB_TX_SHARED flag to priv_flags
Date: Wed, 27 Jul 2011 22:42:08 -0700 (PDT)
Message-ID: <20110727.224208.1562532025453409786.davem@davemloft.net>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
	<1311696338-4739-1-git-send-email-nhorman@tuxdriver.com>
	<1311696338-4739-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert.olsson@its.uu.se,
	eric.dumazet@gmail.com, adobriyan@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696Ab1G1FnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 01:43:19 -0400
In-Reply-To: <1311696338-4739-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 26 Jul 2011 12:05:37 -0400

> Pktgen attempts to transmit shared skbs to net devices, which can't be used by
> some drivers as they keep state information in skbs.  This patch adds a flag
> marking drivers as being able to handle shared skbs in their tx path.  Drivers
> are defaulted to being unable to do so, but calling ether_setup enables this
> flag, as 90% of the drivers calling ether_setup touch real hardware and can
> handle shared skbs.  A subsequent patch will audit drivers to ensure that the
> flag is set properly
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Jiri Pirko <jpirko@redhat.com>

Applied.
