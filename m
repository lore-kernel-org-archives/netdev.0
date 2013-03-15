From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.9-rc2] net: fec: fix missing napi_disable call
Date: Fri, 15 Mar 2013 08:47:41 -0400 (EDT)
Message-ID: <20130315.084741.1699838533506406622.davem@davemloft.net>
References: <1363280049.3967.21.camel@gh-dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grant.likely@secretlab.ca,
	rob.herring@calxeda.com
To: georg@hofmannsweb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460Ab3COMrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 08:47:25 -0400
In-Reply-To: <1363280049.3967.21.camel@gh-dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Georg Hofmann <georg@hofmannsweb.com>
Date: Thu, 14 Mar 2013 17:54:09 +0100

> Commit dc975382d2ef36be7e78fac3717927de1a5abcd8 introduces napi support
> but never calls napi_disable. This will generate a kernel oops
> (kernel BUG at include/linux/netdevice.h:473!) every time, when
> ndo_stop is called followed by ndo_start.
> Add the missing napi_diable call.
> 
> Signed-off-by: Georg Hofmann <georg@hofmannsweb.com>

Applied.
