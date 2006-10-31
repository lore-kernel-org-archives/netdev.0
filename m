From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [SCTP]: Remove temporary associations from backlog
 and hash
Date: Mon, 30 Oct 2006 18:55:29 -0800 (PST)
Message-ID: <20061030.185529.38293277.davem@davemloft.net>
References: <1162258721.22597.40.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7833
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751986AbWJaCz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 21:55:28 -0500
To: sri@us.ibm.com
In-Reply-To: <1162258721.22597.40.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 30 Oct 2006 17:38:41 -0800

> [SCTP]: Remove temporary associations from backlog and hash.
> 
> Every time SCTP creates a temporary association, the stack hashes it,
> puts it on a list of endpoint associations and increments the backlog.
> However, the lifetime of a temporary association is the processing time
> of a current packet and it's destroyed after that. In fact, we don't
> really want anyone else finding this association. There is no reason to
> do this extra work.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Also applied, thanks a lot.

