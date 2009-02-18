From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/43] drivers/net/atlx: fix sparse warnings: fix
 signedness
Date: Tue, 17 Feb 2009 17:26:54 -0800 (PST)
Message-ID: <20090217.172654.50571162.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214211508.23489.57841.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54460
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755877AbZBRB1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:27:10 -0500
In-Reply-To: <20090214211508.23489.57841.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:15:17 +0100

> Impact: While being at it: statics do not need to be initialized with 0.
> 
> Fix this sparse warnings:
>   drivers/net/atlx/atl1.c:109:1: warning: incorrect type in initializer (different signedness)
>   drivers/net/atlx/atl2.c:2870:1: warning: incorrect type in initializer (different signedness)
>   drivers/net/atlx/atl2.c:2880:1: warning: incorrect type in initializer (different signedness)
>   drivers/net/atlx/atl2.c:2894:1: warning: incorrect type in initializer (different signedness)
>   drivers/net/atlx/atl2.c:2904:1: warning: incorrect type in initializer (different signedness)
>   drivers/net/atlx/atl2.c:2913:1: warning: incorrect type in initializer (different signedness)
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
