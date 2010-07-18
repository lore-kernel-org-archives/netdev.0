From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: dccp: fix sign bug
Date: Sun, 18 Jul 2010 15:07:34 -0700 (PDT)
Message-ID: <20100718.150734.22057785.davem@davemloft.net>
References: <1279380060-15394-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, acme@ghostprotocols.net,
	gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37794
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757383Ab0GRWHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 18:07:18 -0400
In-Reply-To: <1279380060-15394-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Sat, 17 Jul 2010 19:21:00 +0400

> 'gap' is unsigned, so this code is wrong:
> 
>     gap = -new_head;
>     ...
>     if (gap > 0) { ... }
> 
> Make 'gap' signed.
> 
> 
> The semantic patch that finds this problem (many false-positive results):
> (http://coccinelle.lip6.fr/)
...
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied, thanks.
