From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fix a memory leak in gianfar close code
Date: Tue, 30 Mar 2010 23:09:03 -0700 (PDT)
Message-ID: <20100330.230903.253520646.davem@davemloft.net>
References: <1269913343-6566-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	Sandeep.Kumar@freescale.com
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56782
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932129Ab0CaGJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:09:02 -0400
In-Reply-To: <1269913343-6566-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Mon, 29 Mar 2010 20:42:23 -0500

> gianfar needed to ensure existence of the *skbuff arrays before
> freeing the skbs in them, rather than ensuring their nonexistence.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Although some refactorings have been suggested, this fixes the bug
straightforwardly and is therefore the most appropriate fix for
net-2.6

Applied, thanks.
