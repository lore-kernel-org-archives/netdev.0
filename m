From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Fix flushing of cached routing informations
Date: Thu, 18 Oct 2012 15:35:57 -0400 (EDT)
Message-ID: <20121018.153557.2118040380508317983.davem@davemloft.net>
References: <20121018052730.GB27385@secunet.com>
	<alpine.LFD.2.00.1210180927230.1572@ja.ssi.bg>
	<20121018071744.GD27385@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533Ab2JRTf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 15:35:59 -0400
In-Reply-To: <20121018071744.GD27385@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 18 Oct 2012 09:17:44 +0200

> Currently we can not flush cached pmtu/redirect informations via
> the ipv4_sysctl_rtcache_flush sysctl. We need to check the rt_genid
> of the old route and reset the nh exeption if the old route is
> expired when we bind a new route to a nh exeption.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied and queued up for -stable, thanks.
