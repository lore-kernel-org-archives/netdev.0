From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: remove old conditions on flow label
 sharing
Date: Tue, 05 Nov 2013 14:41:33 -0500 (EST)
Message-ID: <20131105.144133.43837121028952798.davem@davemloft.net>
References: <1383400507-12604-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florent.fourcot@enst-bretagne.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378Ab3KETlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 14:41:35 -0500
In-Reply-To: <1383400507-12604-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date: Sat,  2 Nov 2013 14:55:07 +0100

> The code of flow label in Linux Kernel follows
> the rules of RFC 1809 (an informational one) for
> conditions on flow label sharing. There rules are
> not in the last proposed standard for flow label
> (RFC 6437), or in the previous one (RFC 3697).
> 
> Since this code does not follow any current or
> old standard, we can remove it.
> 
> With this removal, the ipv6_opt_cmp function is
> now a dead code and it can be removed too.
> 
> Changelog to v1:
>  * add justification for the change
>  * remove the condition on IPv6 options
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Applied, but I had to also remove ipv6_hdr_cmp() as that became unused
as well.

Thanks.
