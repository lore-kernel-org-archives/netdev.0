From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] xfrm4: Don't call icmp_send on local error
Date: Fri, 01 Jul 2011 17:34:49 -0700 (PDT)
Message-ID: <20110701.173449.2101051838955805247.davem@davemloft.net>
References: <20110630091820.GB13201@secunet.com>
	<20110630092041.GD13201@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609Ab1GBAez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 20:34:55 -0400
In-Reply-To: <20110630092041.GD13201@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 30 Jun 2011 11:20:41 +0200

> Calling icmp_send() on a local message size error leads to
> an incorrect update of the path mtu. So use ip_local_error()
> instead to notify the socket about the error.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
