From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sit: remove unnecessary protocol check in
 ipip6_tunnel_xmit()
Date: Thu, 09 Jun 2016 11:23:51 -0700 (PDT)
Message-ID: <20160609.112351.1413951064710022309.davem@davemloft.net>
References: <1465463014-24169-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932938AbcFISXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 14:23:52 -0400
In-Reply-To: <1465463014-24169-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Thu,  9 Jun 2016 18:03:34 +0900

> ipip6_tunnel_xmit() is called immediately after checking that
> skb->protocol is  htons(ETH_P_IPV6) so there is no need
> to check it a second time.
> 
> Found by inspection.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>

Looks good, applied, thanks Simon.
