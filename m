From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] bcm63xx_enet: Remove unnecessary memset of netdev
 private data
Date: Thu, 06 May 2010 22:11:28 -0700 (PDT)
Message-ID: <20100506.221128.35818329.davem@davemloft.net>
References: <1273160458-13039-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49442
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752028Ab0EGFLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 01:11:21 -0400
In-Reply-To: <1273160458-13039-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu,  6 May 2010 17:40:58 +0200

> The memory for the private data is allocated using kzalloc in
> alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
> set it to 0 again.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
