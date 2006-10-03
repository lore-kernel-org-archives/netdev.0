From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: always use hash_mask under tbl lock
Date: Tue, 03 Oct 2006 15:50:26 -0700 (PDT)
Message-ID: <20061003.155026.106265956.davem@davemloft.net>
References: <Pine.LNX.4.58.0610030124220.3580@u.domain.uli>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41914
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030646AbWJCWuY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 18:50:24 -0400
To: ja@ssi.bg
In-Reply-To: <Pine.LNX.4.58.0610030124220.3580@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>
Date: Tue, 3 Oct 2006 03:05:51 +0300 (EEST)

> 
> 	Make sure hash_mask is protected with tbl->lock in all
> cases just like the hash_buckets.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks Julian.  I'll push this to -stable too.
