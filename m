From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2][ATM]: fix possible recursive locking in
 skb_migrate()
Date: Sat, 08 Jul 2006 13:31:19 -0700 (PDT)
Message-ID: <20060708.133119.80011334.davem@davemloft.net>
References: <200607080050.k680oN6l022174@relax.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35037
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030347AbWGHUbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 16:31:34 -0400
To: chas@cmf.nrl.navy.mil
In-Reply-To: <200607080050.k680oN6l022174@relax.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Fri, 07 Jul 2006 20:50:23 -0400

> please consider for 2.6.18 -- thanks!
> 
> [ATM]: fix possible recursive locking in skb_migrate()
> 
> ok this is a real potential deadlock in a way, it takes two locks of 2
> skbuffs without doing any kind of lock ordering; I think the following
> patch should fix it. Just sort the lock taking order by address of the
> skb.. it's not pretty but it's the best this can do in a minimally
> invasive way.
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

Applied, thanks.
