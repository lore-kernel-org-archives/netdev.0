From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] One NET_INC_STATS() could be NET_INC_STATS_BH in
 tcp_v4_err()
Date: Fri, 20 Oct 2006 00:22:43 -0700 (PDT)
Message-ID: <20061020.002243.48819436.davem@davemloft.net>
References: <200610180938.39175.dada1@cosmosbay.com>
	<200610191257.42549.dada1@cosmosbay.com>
	<200610191745.26514.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14226
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S2992546AbWJTHXC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 03:23:02 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200610191745.26514.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 19 Oct 2006 17:45:26 +0200

> I believe this NET_INC_STATS() call can be replaced by  NET_INC_STATS_BH(), a 
> little bit cheaper.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, although I hope tcp_v4_err() never becomes a fast path :-)
