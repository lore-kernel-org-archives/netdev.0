From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bna: bnad_udelay macro cleanup
Date: Thu, 23 Dec 2010 09:38:19 -0800 (PST)
Message-ID: <20101223.093819.104073648.davem@davemloft.net>
References: <1293087949-17613-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46581
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753420Ab0LWRhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 12:37:50 -0500
In-Reply-To: <1293087949-17613-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Wed, 22 Dec 2010 23:05:49 -0800

> Change details:
> 	- Removed unnecessary bnad_udelay macro for ia64
> 
> Signed-off-by: Debashis Dutt <ddutt@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Please don't do it this way.

We don't add known crap, then add a patch to remove the crap.

Respin your BNA patch series so that this IA64 stuff never shows
up in the first place.

Thanks.
