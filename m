From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: remove xerr_idxp from __xfrm_policy_check()
Date: Fri, 01 Sep 2006 00:33:30 -0700 (PDT)
Message-ID: <20060901.003330.18309404.davem@davemloft.net>
References: <Pine.LNX.4.64.0609010054280.22977@d.namei>
	<44F7DE1B.9060503@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11690
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964893AbWIAHdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 03:33:31 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <44F7DE1B.9060503@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Fri, 01 Sep 2006 16:15:39 +0900

> James Morris wrote:
> > It seems that during the MIPv6 respin, some code which was originally 
> > conditionally compiled around CONFIG_XFRM_ADVANCED was accidently left in 
> > after the config option was removed.
> > 
> > This patch removes an extraneous pointer (xerr_idxp) which is no longer 
> > needed.
> > 
> > Please review & apply.
> > 
> > Signed-off-by: James Morris <jmorris@namei.org>
> 
> It seems fine for me.
> David, please apply it.

Applied, thanks everyone.

BTW, the recent mainline bug fix to add a net_ratelimit() call in
net/socket.c created some major conflicts with Stephen Hemminger's RCU
work there, so I had to rebase the net-2.6.19 tree again.

Sorry... :-)
