From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net; ipv[46] - Remove 2 unnecessary NETDEBUG
 OOM messages
Date: Thu, 06 Nov 2014 15:11:33 -0500 (EST)
Message-ID: <20141106.151133.826375379796106384.davem@davemloft.net>
References: <1415134000.23168.7.camel@perches.com>
	<20141105.171623.1142237070388305283.davem@davemloft.net>
	<1415227161.6634.24.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbaKFULg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 15:11:36 -0500
In-Reply-To: <1415227161.6634.24.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 05 Nov 2014 14:39:21 -0800

> These messages aren't useful as there's a generic dump_stack()
> on OOM.
> 
> Neaten the comment and if test above the OOM by separating the
> assign in if into an allocation then if test.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
