From: Bryan O'Sullivan <bos@pathscale.com>
Subject: Re: [PATCH 39 of 39] IB/ipath - use streaming copy in RDMA
	interrupt handler to reduce packet loss
Date: Thu, 29 Jun 2006 14:59:37 -0700
Message-ID: <1151618377.10886.23.camel@chalcedony.pathscale.com>
References: <patchbomb.1151617251@eng-12.pathscale.com>
	 <1b00209ef20a0e7893d8.1151617290@eng-12.pathscale.com>
	 <20060629.145027.41636491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, rdreier@cisco.com, mst@mellanox.co.il,
	openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.pathscale.com ([64.160.42.68]:62865 "EHLO mx.pathscale.com")
	by vger.kernel.org with ESMTP id S933006AbWF2V7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 17:59:39 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060629.145027.41636491.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-29 at 14:50 -0700, David Miller wrote:

> A facility like this doesn't belong in some arbitrary driver layer.
> It belongs as a generic facility the whole kernel could make use
> of.

It could, indeed.  In fact, we had that discussion here before I sent
this patch in.  It presumably wants to live in lib/, and acquire a more
generic name.  What name will capture the uncached-read-but-cached-write
semantics in a useful fashion?  memcpy_nc?

	<b

