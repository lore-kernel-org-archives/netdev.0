From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove CONFIG_KMOD from net/ (towards removing
 CONFIG_KMOD entirely)
Date: Thu, 16 Oct 2008 12:50:46 -0700 (PDT)
Message-ID: <20081016.125046.208151275.davem@davemloft.net>
References: <200810170237.10755.rusty@rustcorp.com.au>
	<48F761C2.4020800@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41981
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753778AbYJPTvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 15:51:09 -0400
In-Reply-To: <48F761C2.4020800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 16 Oct 2008 17:46:10 +0200

> Rusty Russell wrote:
> > Date: Wed, 09 Jul 2008 10:28:42 +0200
> > From: Johannes Berg <johannes@sipsolutions.net>
> > Some code here depends on CONFIG_KMOD to not try to load
> > protocol modules or similar, replace by CONFIG_MODULES
> > where more than just request_module depends on CONFIG_KMOD
> > and and also use try_then_request_module in ebtables.
> > net/netfilter/nfnetlink.c       |    2 +-
> 
> There's a new one in net/netfilter/nf_conntrack_netlink.c
> that is so far only in net-2.6.git, but I assume will be
> merged upstream shortly.

It has been merged :)

Someone send me a patch to kill it off, it's no big deal.
