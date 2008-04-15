From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH 1/1 net-2.6.26] [XFRM]: Compilation warnings in
	xfrm_user.c.
Date: Tue, 15 Apr 2008 09:48:52 +0400
Message-ID: <1208238532.21529.14.camel@iris.sw.ru>
References: <1208178219-18754-1-git-send-email-den@openvz.org>
	 <20080414.144839.258760879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, paul.moore@hp.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:22654 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754276AbYDOFsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 01:48:55 -0400
In-Reply-To: <20080414.144839.258760879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-04-14 at 14:48 -0700, David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Mon, 14 Apr 2008 17:03:39 +0400
> 
> > When CONFIG_SECURITY_NETWORK_XFRM is undefined the following warnings appears:
> > net/xfrm/xfrm_user.c: In function 'xfrm_add_pol_expire':
> > net/xfrm/xfrm_user.c:1576: warning: 'ctx' may be used uninitialized in this function
> > net/xfrm/xfrm_user.c: In function 'xfrm_get_policy':
> > net/xfrm/xfrm_user.c:1340: warning: 'ctx' may be used uninitialized in this function
> > (security_xfrm_policy_alloc is noop for the case).
> > 
> > It seems that they are result of the commit
> > 03e1ad7b5d871d4189b1da3125c2f12d1b5f7d0b
> 
> Needs commit header-line text reference after commit ID, which I've
> added.  I think I've mentioned this issue to you on several occaisions
> already :-/

got it again. Thank you.

