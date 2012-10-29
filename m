From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipv6: introduce ip6_rt_put()
Date: Mon, 29 Oct 2012 17:59:10 +0800
Message-ID: <1351504750.8221.13.camel@cr0>
References: <1351504521-15003-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10947 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758144Ab2J2J7R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 05:59:17 -0400
In-Reply-To: <1351504521-15003-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-29 at 17:55 +0800, Cong Wang wrote:
> -       dst_release(&ifp->rt->dst);
> +       ip6_rt_put(&ifp->rt); 

Oops, should be ip6_rt_put(ifp->rt), don't know why gcc doesn't warn
me...
