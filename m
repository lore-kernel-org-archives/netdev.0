From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: remove old token ipv6 address as soon
 as possible
Date: Tue, 25 Jun 2013 16:30:03 -0700 (PDT)
Message-ID: <20130625.163003.1939592365965386146.davem@davemloft.net>
References: <20130624200328.GJ13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34981 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200Ab3FYXaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:30:04 -0400
In-Reply-To: <20130624200328.GJ13836@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 24 Jun 2013 22:03:28 +0200

> If the tokenized ip address is re-set on an interface we depend on the
> arrival of a new router advertisment to call addrconf_verify to clean
> up the old address (which valid_lft is now set to 0). Old addresses can
> linger around for a longer time if e.g. the source of router advertisments
> vanishes.
> 
> So, call addrconf_verify immediately after setting the new tokenized
> address to get rid of the old tokenized addresses.
> 
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
