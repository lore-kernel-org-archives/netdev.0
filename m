From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [RESEND] [NET] fib_rules: Flush route cache after rule modifications
Date: Wed, 28 Mar 2007 13:19:21 +0200
Message-ID: <20070328111921.GA2703@ff.dom.local>
References: <20070327133845.GM521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, muli@il.ibm.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:48193 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934253AbXC1LOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 07:14:36 -0400
Content-Disposition: inline
In-Reply-To: <20070327133845.GM521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27-03-2007 14:38, Thomas Graf wrote:
> The results of FIB rules lookups are cached in the routing cache
> except for IPv6 as no such cache exists. So far, it was the
> responsibility of the user to flush the cache after modifying any
> rules. This lead to many false bug reports due to misunderstanding
> of this concept.
> 
> This patch automatically flushes the route cache after inserting
> or deleting a rule.

I hope I'm wrong, but isn't this at the cost of admins
working with long rules' sets, which (probably) take extra
time now?

Regards,
Jarek P. 
