From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2015-04-09
Date: Thu, 09 Apr 2015 14:39:57 -0400 (EDT)
Message-ID: <20150409.143957.182724903968436988.davem@davemloft.net>
References: <1428575531-24870-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006AbbDISkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 14:40:00 -0400
In-Reply-To: <1428575531-24870-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 9 Apr 2015 12:32:09 +0200

> 1) We dereferenced the xfrm outer_mode too early, larval
>    SAs don't have it set. Move the dereference of the
>    outer mode below the larval SA check to fix it.
>    From Alexey Dobriyan.
> 
> 2) Fix vti6 tunnel uninit on namespace crosssing.
>    From Yao Xiwei.
> 
> Please pull or let me know if there are problems.

Pulled, thanks a lot Steffen.
