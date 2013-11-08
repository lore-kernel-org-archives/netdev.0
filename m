From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 1/3] ipv6: enable IPV6_FLOWLABEL_MGR for getsockopt
Date: Fri, 8 Nov 2013 13:27:49 +0100
Message-ID: <20131108122749.GA5876@order.stressinduktion.org>
References: <1383843194-22945-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57987 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab3KHM1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 07:27:51 -0500
Content-Disposition: inline
In-Reply-To: <1383843194-22945-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 05:53:12PM +0100, Florent Fourcot wrote:
> It is already possible to set/put/renew a label
> with IPV6_FLOWLABEL_MGR and setsockopt. This patch
> add the possibility to get information about this
> label (current value, time before expiration, etc).
> 
> It helps application to take decision for a renew
> or a release of the label.
> 
> v2:
>  * Add spin_lock to prevent race condition
>  * return -ENOENT if no result found
>  * check if flr_action is GET
> 
> v3:
>  * move the spin_lock to protect only the
>    relevant code
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

There still are some locking anomalies in ip6_flowlabel. But none
has something to do with your patches. E.g. mem_check runs without
rcu_read_lock.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
