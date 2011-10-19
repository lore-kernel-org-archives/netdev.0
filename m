From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Allow skb_recycle_check to be done in stages
Date: Wed, 19 Oct 2011 16:00:02 -0400 (EDT)
Message-ID: <20111019.160002.1466712773120379478.davem@davemloft.net>
References: <1318516435-24314-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527Ab1JSUAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 16:00:08 -0400
In-Reply-To: <1318516435-24314-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Thu, 13 Oct 2011 09:33:54 -0500

> skb_recycle_check resets the skb if it's eligible for recycling.
> However, there are times when a driver might want to optionally
> manipulate the skb data with the skb before resetting the skb,
> but after it has determined eligibility.  We do this by splitting the
> eligibility check from the skb reset, creating two inline functions to
> accomplish that task.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.
