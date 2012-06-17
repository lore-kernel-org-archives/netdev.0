From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 02/02] net/ipv4: VTI support new module for
 ip_vti.
Date: Sun, 17 Jun 2012 16:27:17 -0700 (PDT)
Message-ID: <20120617.162717.1814684296202502234.davem@davemloft.net>
References: <20120614091254.GT27795@secunet.com>
	<c2becb86-be73-4668-be84-82293c6c56fc@tahiti.vyatta.com>
	<20120615053707.GV27795@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saurabh.mohan@vyatta.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab2FQX1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 19:27:18 -0400
In-Reply-To: <20120615053707.GV27795@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 15 Jun 2012 07:37:07 +0200

> VTI should be independent of the IPsec protocol.
> Our IPsec implementation supports AH (and IPCOMP)
> so VTI should support these protocols too.

I agree with Steffen, it shouldn't require very much work to support
all of the 3 major IPSEC protocols.  So if we are going to add a
feature like this I require that you completely flesh out the support
and support IPV6 as well.

Doing otherwise creates a terrible user experience.
