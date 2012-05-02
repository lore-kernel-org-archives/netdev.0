From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] net: ipv4: ipconfig: decrease CONF_CARRIER_TIMEOUT
Date: Wed, 02 May 2012 19:43:17 -0400 (EDT)
Message-ID: <20120502.194317.508423029651293123.davem@davemloft.net>
References: <1335972259-20975-1-git-send-email-c.hemp@phytec.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: c.hemp@phytec.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985Ab2EBXqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 19:46:23 -0400
In-Reply-To: <1335972259-20975-1-git-send-email-c.hemp@phytec.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Hemp <c.hemp@phytec.de>
Date: Wed, 2 May 2012 17:24:19 +0200

> A timeout of two minutes is pretty anoying if _no_ ethernet cable
> is attached by purpose.  This patch decreases the timeout of
> CONF_CARRIER_TIMEOUT to an accaptable value of 10 secounds.
> 
> Signed-off-by: Christian Hemp <c.hemp@phytec.de>

It was increased to 2 minutes intentionally, therefore you better go
look into the history of why this was done and you better explain in
your commit message why those issues don't matter.

Otherwise your patch will be completely ignored.
