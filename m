From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] gianfar: Fix overflow check and return value for
 gfar_get_cls_all()
Date: Tue, 20 Sep 2011 15:40:24 -0400 (EDT)
Message-ID: <20110920.154024.2283577184578018343.davem@redhat.com>
References: <1315349065.2788.18.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.poehn@belden.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763Ab1ITTk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 15:40:28 -0400
In-Reply-To: <1315349065.2788.18.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 06 Sep 2011 23:44:25 +0100

> This function may currently fill one entry beyond the end of the
> array it is given.  It also doesn't return an error code in case
> it does detect overflow.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks a lot Ben.
