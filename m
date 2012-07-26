From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] pch_gbe: vlan skb len fix
Date: Thu, 26 Jul 2012 14:31:42 -0700 (PDT)
Message-ID: <20120726.143142.935341464119402864.davem@davemloft.net>
References: <20120726160117.GD10287@telcoserv5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andycress@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753606Ab2GZVbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 17:31:43 -0400
In-Reply-To: <20120726160117.GD10287@telcoserv5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Cress <andycress@gmail.com>
Date: Thu, 26 Jul 2012 12:01:17 -0400

> 
> pch_gbe_xmit_frame skb->len verification was incorrect in vlan case 
> causing bogus transfer length errors.  One correction could be:
>     offset = skb->protocol == htons(ETH_P_8021Q) ? 0 : 4;
>     if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - offset))) 
> However, this verification is not necessary, so remove it.
> 
> Signed-off-by: Andy Cress <andy.cress@us.kontron.com>

Applied.
