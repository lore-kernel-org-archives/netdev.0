From: David Miller <davem@redhat.com>
Subject: Re: [RFC PATCH] sctp: Don't lookup dst if transport dst is still
 valid
Date: Fri, 12 Jul 2013 15:58:08 -0700 (PDT)
Message-ID: <20130712.155808.2237731776440357524.davem@redhat.com>
References: <51D6D3A0.7050106@gmail.com>
	<51DC282C.9090007@gmail.com>
	<51DF74BE.6000001@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36391 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757839Ab3GLW6S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jul 2013 18:58:18 -0400
In-Reply-To: <51DF74BE.6000001@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Fri, 12 Jul 2013 11:15:10 +0800

> But problem still arise when we attempt to delete address
> in multi-home mode, deleting an IPv6 address does not invalidate
> any dst which source address is the same at the deleted one.
> Which means sctp cannot rely on ip6_dst_check in this scenario.

I still cannot understand why this is an SCTP specific issue.

Specifically, I cannot see why address addition/deletion doesn't
cause problems for cached ipv6 routes in UDP and TCP sockets too.
