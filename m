From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: ip: push gso skb forwarding handling down the
 stack
Date: Wed, 07 May 2014 15:49:40 -0400 (EDT)
Message-ID: <20140507.154940.261459809114586136.davem@davemloft.net>
References: <1399294844-7231-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaEGTtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 15:49:42 -0400
In-Reply-To: <1399294844-7231-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon,  5 May 2014 15:00:42 +0200

> Turns out doing the segmentation in forwarding was not a bright idea,
> there are corner-cases where this has unintended side-effects.
> 
> This patch pushes the segmentation downwards.

Series applied, thanks Florian.
