From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] ipv6: Add lockless UDP send path
Date: Mon, 02 Feb 2015 19:28:45 -0800 (PST)
Message-ID: <20150202.192845.885503646752052740.davem@davemloft.net>
References: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	hannes@stressinduktion.org, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074AbbBCD2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 22:28:46 -0500
In-Reply-To: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Sat, 31 Jan 2015 10:40:12 -0500

> This series introduces a lockless UDPv6 send path similar to
> what Herbert Xu did for IPv4 a while ago.
> 
> There are some difference from IPv4.  IPv6 caching for flow
> label is a bit different, as well as it requires another cork
> cork structure that holds the IPv6 ancillary data.
> 
> Please take a look.

This looks good to me, applied, thanks Vlad.
