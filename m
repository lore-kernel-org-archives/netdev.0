From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NET: ksz884x, fix lock imbalance
Date: Tue, 16 Mar 2010 14:28:26 -0700 (PDT)
Message-ID: <20100316.142826.115796003.davem@davemloft.net>
References: <1268751230-14416-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Tristram.Ha@micrel.com
To: jslaby@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41918
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754364Ab0CPV2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 17:28:04 -0400
In-Reply-To: <1268751230-14416-1-git-send-email-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jslaby@suse.cz>
Date: Tue, 16 Mar 2010 15:53:50 +0100

> Stanse found that one error path (when alloc_skb fails) in netdev_tx
> omits to unlock hw_priv->hwlock. Fix that.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Tristram Ha <Tristram.Ha@micrel.com>
> Cc: David S. Miller <davem@davemloft.net>

Applied, thanks.
