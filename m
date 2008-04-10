From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] fib_trie: memory waste solutions
Date: Thu, 10 Apr 2008 02:57:17 -0700 (PDT)
Message-ID: <20080410.025717.04755660.davem@davemloft.net>
References: <20080404090257.2ec38b0c@extreme>
	<47FA4FE5.5010500@cosmosbay.com>
	<20080407154800.6912ad1d@speedy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, shemminger@vyatta.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53675
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752198AbYDJJ5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 05:57:17 -0400
In-Reply-To: <20080407154800.6912ad1d@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Mon, 7 Apr 2008 15:48:00 -0700

> On Mon, 07 Apr 2008 18:46:29 +0200
> Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> > I prefer my patch Stephen, as your version enlarges every tnode with an 
> > embedded "struct work_struct" which can be larger than a "struct rcu_head"
> 
> The number of tnode's is small and the size growth of 2*(unsigned long) is not
> worth worrying about. Also theoretically, my version could have multiple
> work elements processed at once.

I pretty much agree with Stephen and thus applied his patch
to net-2.6.26.

We can tweak this further if new data supports that.
