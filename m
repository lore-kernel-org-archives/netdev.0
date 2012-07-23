From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Change rt->rt_iif encoding.
Date: Mon, 23 Jul 2012 16:05:41 -0700 (PDT)
Message-ID: <20120723.160541.184307938805782289.davem@davemloft.net>
References: <20120723.140737.822125500680433996.davem@davemloft.net>
	<20120723.152220.822947775372843073.davem@davemloft.net>
	<alpine.LFD.2.00.1207240157120.2404@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab2GWXFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 19:05:42 -0400
In-Reply-To: <alpine.LFD.2.00.1207240157120.2404@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Tue, 24 Jul 2012 02:11:38 +0300 (EEST)

> skb_iif: ifindex of device we arrived on
> 
> 	If it has hidden semantic may be we can make this
> comment more specific, does it survive some loops?

Strangely I hadn't noticed this, and after the email I just sent
out I was going to look into adding such a value :-)

Great!

I'll respin my patches to use that thing, thanks Julian.
