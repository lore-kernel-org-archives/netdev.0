From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bnx2x: use the default NAPI weight
Date: Tue, 05 Mar 2013 23:59:22 -0500 (EST)
Message-ID: <20130305.235922.483938589207493211.davem@davemloft.net>
References: <1362535067.15793.146.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60891 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755163Ab3CFE7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 23:59:23 -0500
In-Reply-To: <1362535067.15793.146.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Mar 2013 17:57:47 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> BQL (Byte Queue Limits) proper operation needs TX completion
> being serviced in a timely fashion.
> 
> bnx2x uses a non standard NAPI poll weight, and thats not fair to other
> napi poll handlers, and even not reasonable.
> 
> Use the default value instead.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Eilon Greenstein <eilong@broadcom.com>

Applied.
