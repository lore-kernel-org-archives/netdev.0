From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH 0/2] macvlan: Avoid unnecessary multicast cloning
Date: Wed, 01 Jun 2016 17:49:22 -0700 (PDT)
Message-ID: <20160601.174922.190841350350542759.davem@davemloft.net>
References: <20160530082828.GB5106@gondor.apana.org.au>
	<20160531.140713.2187659962450926738.davem@davemloft.net>
	<20160601034218.GA31335@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, kaber@trash.net, netdev@vger.kernel.org,
	jpirko@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49939 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbcFBAtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 20:49:24 -0400
In-Reply-To: <20160601034218.GA31335@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 1 Jun 2016 11:42:18 +0800

> This patch tries to improve macvlan multicast performance by
> maintaining a filter hash at the macvlan_port level so that we
> can quickly determine whether a given packet is needed or not.
> 
> It is preceded by a patch that fixes a potential use-after-free
> bug that I discovered while looking over this.
> 
> v2 fixed a bug where promiscuous/allmulti settings weren't handled
> correctly.

Series applied to net-next, thanks Herbert.
