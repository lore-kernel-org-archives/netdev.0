From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: fib_trie leaf free optimization
Date: Thu, 10 Apr 2008 03:47:47 -0700 (PDT)
Message-ID: <20080410.034747.56375808.davem@davemloft.net>
References: <20080402215724.4cf5fbf0@extreme>
	<20080402215859.7d024d19@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51558
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751605AbYDJKrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 06:47:46 -0400
In-Reply-To: <20080402215859.7d024d19@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 2 Apr 2008 21:58:59 -0700

> Avoid unneeded test in the case where object to be freed
> has to be a leaf. Don't need to use the generic tnode_free()
> function, instead just setup leaf to be freed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
