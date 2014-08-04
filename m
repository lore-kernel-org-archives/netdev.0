From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] xfrm: scalability enhancements for
 policy database
Date: Mon, 04 Aug 2014 15:09:22 -0700 (PDT)
Message-ID: <20140804.150922.1383964106587443773.davem@davemloft.net>
References: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
	<1406884348-12423-1-git-send-email-christophe.gouault@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: christophe.gouault@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46563 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843AbaHDWJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 18:09:23 -0400
In-Reply-To: <1406884348-12423-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe Gouault <christophe.gouault@6wind.com>
Date: Fri,  1 Aug 2014 11:12:26 +0200

> This patchset enables to hash more policies than just non-prefixed
> ones: hash policies whose prefix lengths are greater or equal to
> configurable thresholds.
> 
> These thresholds are configured via netlink message
> XFRM_MSG_NEWSPDINFO, attributes XFRMA_SPD_IPV4_HTHRESH and
> XFRMA_SPD_IPV6_HTHRESH.
> 
> The related iproute2 patch for configuring the thresholds is available
> on demand.

Since this is not urgent, and a new feature, I'll let Steffen review this
when he gets back.
