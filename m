From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 0/2] netns: fix for NULL-dereference in ipv6 code
Date: Thu, 14 Aug 2008 16:17:07 -0400
Message-ID: <48A492C3.7080502@hp.com>
References: <48A48717.4020609@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	containers <containers@lists.osdl.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:16119 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655AbYHNURK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 16:17:10 -0400
In-Reply-To: <48A48717.4020609@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley wrote:
> Hi,
> 
> When fixing the NULL-dereference of the idev in rt6_fill_node(), I
> noticed that dev_net() doesn't handle a NULL argument either.  These two
> patches fix that, as well as add a network namespace argument to
> rt6_fill_node() and ipv6_dev_get_saddr().

Brian

What is the reason that dev_net() would need to handle a NULL arg?

I think a NULL pointer in dev_net is a bug if Network Namespaces are used.

-vlad
