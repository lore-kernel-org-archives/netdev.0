From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND] [NET] fib_rules: Flush route cache after rule
 modifications
Date: Tue, 27 Mar 2007 13:57:07 -0700 (PDT)
Message-ID: <20070327.135707.32346804.davem@davemloft.net>
References: <20070327133845.GM521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, muli@il.ibm.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934205AbXC0U5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 16:57:08 -0400
In-Reply-To: <20070327133845.GM521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 27 Mar 2007 15:38:45 +0200

> The results of FIB rules lookups are cached in the routing cache
> except for IPv6 as no such cache exists. So far, it was the
> responsibility of the user to flush the cache after modifying any
> rules. This lead to many false bug reports due to misunderstanding
> of this concept.
> 
> This patch automatically flushes the route cache after inserting
> or deleting a rule.
> 
> Thanks to Muli Ben-Yehuda <muli@il.ibm.com> for catching a bug
> in the previous patch.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
