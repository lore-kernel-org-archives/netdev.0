From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] ipv6: remove old conditions on flow label sharing
Date: Mon, 4 Nov 2013 00:17:08 +0100
Message-ID: <20131103231708.GA8832@order.stressinduktion.org>
References: <1383400507-12604-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47369 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957Ab3KCXRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 18:17:09 -0500
Content-Disposition: inline
In-Reply-To: <1383400507-12604-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 02, 2013 at 02:55:07PM +0100, Florent Fourcot wrote:
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

Yup, makes sense.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
