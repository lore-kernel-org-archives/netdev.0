From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] act_pedit: access skb->data safely
Date: Thu, 03 Jun 2010 03:30:18 -0700 (PDT)
Message-ID: <20100603.033018.112821473.davem@davemloft.net>
References: <1275490502-22608-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933843Ab0FCKaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:30:08 -0400
In-Reply-To: <1275490502-22608-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed,  2 Jun 2010 22:55:02 +0800

> access skb->data safely
> 
> we should use skb_header_pointer() and skb_store_bits() to access skb->data to
> handle small or non-linear skbs.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
