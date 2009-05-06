From: David Miller <davem@davemloft.net>
Subject: Re: net-sched: fix bfifo default limit
Date: Wed, 06 May 2009 16:45:16 -0700 (PDT)
Message-ID: <20090506.164516.13167313.davem@davemloft.net>
References: <4A019210.5000108@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43709
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751245AbZEFXpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 19:45:22 -0400
In-Reply-To: <4A019210.5000108@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 06 May 2009 15:35:12 +0200

> net-sched: fix bfifo default limit
> 
> When no limit is given, the bfifo uses a default of tx_queue_len * mtu.
> Packets handled by qdiscs include the link layer header, so this should
> be taken into account, similar to what other qdiscs do.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks a lot!
