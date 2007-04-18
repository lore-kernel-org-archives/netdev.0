From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make dev_kfree_skb_any check if the skb is valid
Date: Wed, 18 Apr 2007 15:44:16 -0700 (PDT)
Message-ID: <20070418.154416.131918019.davem@davemloft.net>
References: <20070418223339.GE13146@hovland.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, trivial@kernel.org
To: erik@hovland.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45434
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932274AbXDRWoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 18:44:13 -0400
In-Reply-To: <20070418223339.GE13146@hovland.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Erik Hovland <erik@hovland.org>
Date: Wed, 18 Apr 2007 15:33:44 -0700

> If dev_kfree_skb_any is called and it then calls dev_kfree_skb_irq.
> That call will dereference the skb. If the skb is invalid, down the
> drain we go.
> 
> This one-liner checks to see if the skb is valid as part of the
> determination of whether to call dev_kfree_skb_irq.
> 
> Signed-off-by: Erik Hovland <erik@hovland.org>

This should never be invoked with a NULL skb argument.

Who is doing that?
