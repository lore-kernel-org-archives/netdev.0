From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 38/43] drivers/net/wireless: fix sparse warnings:
 symbol shadows an earlier one
Date: Tue, 17 Feb 2009 19:35:35 -0800 (PST)
Message-ID: <20090217.193535.170390441.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214214852.24377.70239.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59014
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754760AbZBRDfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 22:35:50 -0500
In-Reply-To: <20090214214852.24377.70239.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:49:09 +0100

> Impact:
>   Move variable closer to usage resp.
>   remove redundant variables resp.
>   rename function scope variable.
> 
> Fix this sparse warnings:
>   drivers/net/wireless/airo.c:3840:29: warning: symbol 'i' shadows an earlier one
>   drivers/net/wireless/airo.c:3751:13: originally declared here
>   drivers/net/wireless/airo.c:3847:29: warning: symbol 'i' shadows an earlier one
>   drivers/net/wireless/airo.c:3751:13: originally declared here
>   drivers/net/wireless/airo.c:3861:21: warning: symbol 'i' shadows an earlier one
>   drivers/net/wireless/airo.c:3751:13: originally declared here
>   drivers/net/wireless/wavelan.c:43:13: warning: symbol 'irq' shadows an earlier one
>   drivers/net/wireless/wavelan.p.h:692:17: originally declared here
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
