From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Remove CONFIG_KMOD from net/ (towards removing CONFIG_KMOD
 entirely)
Date: Thu, 16 Oct 2008 17:46:10 +0200
Message-ID: <48F761C2.4020800@trash.net>
References: <200810170237.10755.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37620 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753942AbYJPPqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 11:46:16 -0400
In-Reply-To: <200810170237.10755.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> Date: Wed, 09 Jul 2008 10:28:42 +0200
> From: Johannes Berg <johannes@sipsolutions.net>
> 
> Some code here depends on CONFIG_KMOD to not try to load
> protocol modules or similar, replace by CONFIG_MODULES
> where more than just request_module depends on CONFIG_KMOD
> and and also use try_then_request_module in ebtables.
> 
>  net/netfilter/nfnetlink.c       |    2 +-

There's a new one in net/netfilter/nf_conntrack_netlink.c
that is so far only in net-2.6.git, but I assume will be
merged upstream shortly.
