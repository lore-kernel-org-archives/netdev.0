From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: cleanup of local_port_range
Date: Wed, 08 Oct 2008 14:18:12 -0700 (PDT)
Message-ID: <20081008.141812.195676240.davem@davemloft.net>
References: <48ED2296.1090003@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44998
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751643AbYJHVSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 17:18:36 -0400
In-Reply-To: <48ED2296.1090003@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 08 Oct 2008 23:13:58 +0200

> I noticed sysctl_local_port_range[] and its associated seqlock
> sysctl_local_port_range_lock were on separate cache lines.
> Moreover, sysctl_local_port_range[] was close to unrelated
> variables, highly modified, leading to cache misses.
> 
> Moving these two variables in a structure can help data
> locality and moving this structure to read_mostly section
> helps sharing of this data among cpus.
> 
> Cleanup of extern declarations (moved in include file where
> they belong), and use of inet_get_local_port_range()
> accessor instead of direct access to ports values.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
