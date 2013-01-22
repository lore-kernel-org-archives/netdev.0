From: David Miller <davem@davemloft.net>
Subject: Re: pull request: ipsec 2013-01-22
Date: Tue, 22 Jan 2013 14:21:23 -0500 (EST)
Message-ID: <20130122.142123.1616754423891464190.davem@davemloft.net>
References: <1358845596-2066-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472Ab3AVTV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 14:21:26 -0500
In-Reply-To: <1358845596-2066-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 22 Jan 2013 10:06:31 +0100

> 1) The transport header did not point to the right place after
>    esp/ah processing on tunnel mode in the receive path. As a
>    result, the ECN field of the inner header was not set correctly,
>    fixes from Li RongQing.
> 
> 2) We did a null check too late in one of the xfrm_replay advance
>    functions. This can lead to a division by zero, fix from
>    Nickolai Zeldovich.
> 
> 3) The size calculation of the hash table missed the muiltplication
>    with the actual struct size when the hash table is freed.
>    We might call the wrong free function, fix from Michal Kubecek.
> 
> 4) On IPsec pmtu events we can't access the transport headers of
>    the original packet, so force a relookup for all routes
>    to notify about the pmtu event.
> 
> Please pull or let me know if there are problems.

Pulled, thakns a lot.

Please be explicit in the future about what tree a set of changes are
targetted at.

Thanks.
