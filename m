From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-2.6.26] [XFRM]: Compilation warnings in
 xfrm_user.c.
Date: Mon, 14 Apr 2008 14:48:39 -0700 (PDT)
Message-ID: <20080414.144839.258760879.davem@davemloft.net>
References: <1208178219-18754-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, paul.moore@hp.com,
	netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35478
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751725AbYDNVsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 17:48:38 -0400
In-Reply-To: <1208178219-18754-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Mon, 14 Apr 2008 17:03:39 +0400

> When CONFIG_SECURITY_NETWORK_XFRM is undefined the following warnings appears:
> net/xfrm/xfrm_user.c: In function 'xfrm_add_pol_expire':
> net/xfrm/xfrm_user.c:1576: warning: 'ctx' may be used uninitialized in this function
> net/xfrm/xfrm_user.c: In function 'xfrm_get_policy':
> net/xfrm/xfrm_user.c:1340: warning: 'ctx' may be used uninitialized in this function
> (security_xfrm_policy_alloc is noop for the case).
> 
> It seems that they are result of the commit
> 03e1ad7b5d871d4189b1da3125c2f12d1b5f7d0b

Needs commit header-line text reference after commit ID, which I've
added.  I think I've mentioned this issue to you on several occaisions
already :-/

> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks.
