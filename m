From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] reduce sizeof(struct flowi) by 20 bytes
Date: Sat, 21 Oct 2006 20:25:17 -0700 (PDT)
Message-ID: <20061021.202517.52167649.davem@davemloft.net>
References: <200610181055.32102.dada1@cosmosbay.com>
	<20061018124202.GA31981@fogou.chygwyn.com>
	<200610201555.33736.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve@chygwyn.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51889
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422932AbWJVDZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Oct 2006 23:25:12 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200610201555.33736.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 20 Oct 2006 15:55:33 +0200

> As suggested by David, just kill off some unused fields in dnports to reduce 
> sizef(struct flowi). If they come back, they should be moved to nl_u.dn_u in 
> order not to enlarge again struct flowi
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, except I changed the patch to really delete this
stuff instead of using "#if 0".  Anyone can look into old
trees of the code history to see the old stuff. :-)

Thanks Eric.
