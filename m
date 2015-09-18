From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_dsmark: improve memory locality
Date: Thu, 17 Sep 2015 22:37:59 -0700 (PDT)
Message-ID: <20150917.223759.1258155849005087677.davem@davemloft.net>
References: <1442533033.7946.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48690 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbbIRFiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 01:38:00 -0400
In-Reply-To: <1442533033.7946.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Sep 2015 16:37:13 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Memory placement in sch_dsmark is silly : Better place mask/value
> in the same cache line.
> 
> Also, we can embed small arrays in the first cache line and
> remove a potential cache miss.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
