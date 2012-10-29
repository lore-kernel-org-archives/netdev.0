From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next] ipv4: avoid a test in ip_rt_put()
Date: Mon, 29 Oct 2012 17:09:06 +0800
Message-ID: <1351501746.8221.12.camel@cr0>
References: <1351499603.7394.199.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755128Ab2J2JJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 05:09:11 -0400
In-Reply-To: <1351499603.7394.199.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-29 at 09:33 +0100, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> We can save a test in ip_rt_put(), considering dst_release() accepts
> a NULL parameter, and dst is first element in rtable.
> 
> Add a BUILD_BUG_ON() to catch any change that could break this
> assertion.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Cong Wang <amwang@redhat.com>

Acked-by: Cong Wang <amwang@redhat.com>

Thanks!
