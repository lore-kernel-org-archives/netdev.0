From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4: Remove output route check in ipv4_mtu
Date: Thu, 17 Jan 2013 03:40:33 -0500 (EST)
Message-ID: <20130117.034033.216761121604251913.davem@davemloft.net>
References: <20130117065500.GG18940@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, timo.teras@iki.fi, luky-37@hotmail.com,
	pupilla@libero.it, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759215Ab3AQIkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 03:40:36 -0500
In-Reply-To: <20130117065500.GG18940@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 17 Jan 2013 07:55:01 +0100

> The output route check was introduced with git commit 261663b0
> (ipv4: Don't use the cached pmtu informations for input routes)
> during times when we cached the pmtu informations on the
> inetpeer. Now the pmtu informations are back in the routes,
> so this check is obsolete. It also had some unwanted side effects,
> as reported by Timo Teras and Lukas Tribus.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied and queued up for -stable.
