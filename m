From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: do not expire TCP fastopen cookies
Date: Sun, 05 May 2013 16:58:43 -0400 (EDT)
Message-ID: <20130505.165843.1494729481746369326.davem@davemloft.net>
References: <1367644365.22983.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440Ab3EEU6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 May 2013 16:58:44 -0400
In-Reply-To: <1367644365.22983.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 May 2013 22:12:45 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP metric cache expires entries after one hour.
> 
> This probably make sense for TCP RTT/RTTVAR/CWND, but not
> for TCP fastopen cookies.
> 
> Its better to try previous cookie. If it appears to be obsolete,
> server will send us new cookie anyway.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
