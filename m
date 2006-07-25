From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] tg3: Handle tg3_init_rings() failures
Date: Tue, 25 Jul 2006 16:38:39 -0700 (PDT)
Message-ID: <20060725.163839.12157257.davem@davemloft.net>
References: <1153868180.3167.27.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sdoyon@max-t.com, howie@vmware.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44452
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030260AbWGYXiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 19:38:24 -0400
To: mchan@broadcom.com
In-Reply-To: <1153868180.3167.27.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 25 Jul 2006 15:56:20 -0700

> Handle dev_alloc_skb() failures when initializing the RX rings.
> Without proper handling, the driver will crash when using a partial
> ring.
> 
> Thanks to Stephane Doyon <sdoyon@max-t.com> for reporting the bug and
> providing the initial patch.
> 
> Howie Xu <howie@vmware.com> also reported the same issue.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks a lot.
