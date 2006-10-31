From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: return EINVAL for invalid address with flowlabel
 lease request
Date: Mon, 30 Oct 2006 18:56:18 -0800 (PST)
Message-ID: <20061030.185618.98778538.davem@davemloft.net>
References: <Pine.LNX.4.64.0610301914230.10915@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9881
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751987AbWJaC4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 21:56:16 -0500
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0610301914230.10915@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Mon, 30 Oct 2006 19:31:31 -0500 (EST)

> Currently, when an application requests a lease for a flowlabel via the 
> IPV6_FLOWLABEL_MGR socket option, no error is returned if an invalid type 
> of destination address is supplied as part of the request, leading to a 
> silent failure.  This patch ensures that EINVAL is returned to the 
> application in this case.
> 
> Please apply.
> 
> Signed-off-by: James Morris <jmorris@namei.org>

Applied, thanks a lot James.
