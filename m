From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [iproute] ipxfrm: simplify algo code a bit
Date: Thu, 17 Jan 2013 22:26:46 -0500 (EST)
Message-ID: <20130117.222646.675735349628953028.davem@davemloft.net>
References: <1358476746-10810-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930Ab3ARD0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 22:26:49 -0500
In-Reply-To: <1358476746-10810-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Thu, 17 Jan 2013 21:39:06 -0500

> The current code sets up a structure with xfrm_algo embedded in it, but
> doesn't use the supplemental key field.  Drop it.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

It's for the storage of the zero length array at the end of
xfrm_algo.

Don't change code you don't understand.
