From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [ipsec-next v4 0/2] xfrm: scalability enhancements for policy
 database
Date: Wed, 3 Sep 2014 13:59:13 +0200
Message-ID: <20140903115913.GH6390@secunet.com>
References: <20140829095431.GF6390@secunet.com>
 <1409321765-2012-1-git-send-email-christophe.gouault@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53984 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932066AbaICL7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 07:59:25 -0400
Content-Disposition: inline
In-Reply-To: <1409321765-2012-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 29, 2014 at 04:16:03PM +0200, Christophe Gouault wrote:
> This patchset enables to hash more policies than just non-prefixed
> ones: hash policies whose prefix lengths are greater or equal to
> configurable thresholds.
> 
> These thresholds are configured via netlink message
> XFRM_MSG_NEWSPDINFO, attributes XFRMA_SPD_IPV4_HTHRESH and
> XFRMA_SPD_IPV6_HTHRESH.
> 
> The related iproute2 patch for configuring the thresholds is available
> on demand.
> 
> Best Regards,
> Christophe
> ----
> v2:
> - change configuration API from proc to netlink
> v3:
> - initialize xfrm_policy_hthresh lock
> - remove "rebuilding SPD hash table" log
> - replace deprecated hlist_add_after by hlist_add_behind
> - remove netlink reply to XFRM_MSG_NEWSPDINFO request
> v4:
> - remove unused variables in xfrm_set_spdinfo

Looks good. All applied to ipsec-next, thanks a lot Christophe!
