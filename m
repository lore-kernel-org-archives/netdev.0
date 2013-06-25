From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: split duplicate address detection and
 router solicitation timer
Date: Tue, 25 Jun 2013 16:23:58 -0700 (PDT)
Message-ID: <20130625.162358.2018248422018779273.davem@davemloft.net>
References: <20130623163901.GB13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fleitner@redhat.com,
	yoshfuji@linux-ipv6.org, dlstevens@us.ibm.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab3FYXYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:24:01 -0400
In-Reply-To: <20130623163901.GB13836@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 23 Jun 2013 18:39:01 +0200

> This patch splits the timers for duplicate address detection and router
> solicitations apart. The router solicitations timer goes into inet6_dev
> and the dad timer stays in inet6_ifaddr.
> 
> The reason behind this patch is to reduce the number of unneeded router
> solicitations send out by the host if additional link-local addresses
> are created. Currently we send out RS for every link-local address on
> an interface.
> 
> If the RS timer fires we pick a source address with ipv6_get_lladdr. This
> change could hurt people adding additional link-local addresses and
> specifying these addresses in the radvd clients section because we
> no longer guarantee that we use every ll address as source address in
> router solicitations.
> 
> Cc: Flavio Leitner <fleitner@redhat.com>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: David Stevens <dlstevens@us.ibm.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
