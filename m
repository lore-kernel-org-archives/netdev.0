From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: dsa: change tag_protocol to an enum
Date: Sat, 13 Sep 2014 17:04:47 -0400 (EDT)
Message-ID: <20140913.170447.801906348037109799.davem@davemloft.net>
References: <1410495489-7050-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@wantstofly.org,
	alexander.duyck@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbaIMVEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 17:04:49 -0400
In-Reply-To: <1410495489-7050-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 11 Sep 2014 21:18:09 -0700

> Now that we introduced an additional multiplexing/demultiplexing layer
> with commit 3e8a72d1dae37 ("net: dsa: reduce number of protocol hooks")
> that lives within the DSA code, we no longer need to have a given switch
> driver tag_protocol be an actual ethertype value, instead, we can
> replace it with an enum: dsa_tag_protocol.
> 
> Do this replacement in the drivers, which allows us to get rid of the
> cpu_to_be16()/htons() dance, and remove ETH_P_BRCMTAG since we do not
> need it anymore.
> 
> Suggested-by: Alexander Duyck <alexander.duyck@gmail.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v2:
> - removed now obsolete comment about the former ETH_P_BRCMTAG we did
>   introduce earlier

Applied, thank you.
