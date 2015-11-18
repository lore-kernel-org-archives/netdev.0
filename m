From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dns_resolver: convert time_t to time64_t
Date: Wed, 18 Nov 2015 15:20:25 -0500 (EST)
Message-ID: <20151118.152025.1846834961092956563.davem@davemloft.net>
References: <20151118063643.GA16239@waves>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, dhowells@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mahfouz.saif.elyazal@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754683AbbKRUU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 15:20:28 -0500
In-Reply-To: <20151118063643.GA16239@waves>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Wed, 18 Nov 2015 08:36:44 +0200

> Changes the definition of the pointer _expiry from time_t to
> time64_t. This is to handle the Y2038 problem where time_t
> will overflow in the year 2038. The change is safe because
> the kernel subsystems that call dns_query pass NULL.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
> ---
> Changelog:
> v1: The changes were originally made by Arnd Bergmann in
> relation to time_t. I've broken down a patch sent to me
> into two independent patches.

Want me to apply this to 'net'?
