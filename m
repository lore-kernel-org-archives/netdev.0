From: David Miller <davem@davemloft.net>
Subject: Re: [NET] netfilter : xt_time should not assume CONFIG_KTIME_SCALAR
Date: Tue, 13 Nov 2007 03:50:19 -0800 (PST)
Message-ID: <20071113.035019.268404275.davem@davemloft.net>
References: <47398ADD.2030509@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43378
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754556AbXKMLuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 06:50:20 -0500
In-Reply-To: <47398ADD.2030509@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 13 Nov 2007 12:30:37 +0100

> It is not correct to assume one can get nsec from a ktime directly by 
> using .tv64 field.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Patrick, this is very clearly a correct bug fix, so I'm
going to apply this directly.

Applied, thanks Eric.
