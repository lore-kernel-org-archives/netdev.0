From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: fix two caif_connect() bugs
Date: Tue, 05 Oct 2010 20:38:58 -0700 (PDT)
Message-ID: <20101005.203858.115928630.davem@davemloft.net>
References: <1286268128.2796.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sjur.brandeland@stericsson.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57981
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758579Ab0JFDih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 23:38:37 -0400
In-Reply-To: <1286268128.2796.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Oct 2010 10:42:08 +0200

> caif_connect() might dereference a netdevice after dev_put() it.
> 
> It also doesnt check dev_get_by_index() return value and could
> dereference a NULL pointer.
> 
> Fix it, using RCU to avoid taking a reference.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
