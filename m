From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix 'inet6_rtm_getroute' to release 'rt->dst' in
 case of 'alloc_skb' failure
Date: Wed, 04 Apr 2012 05:26:17 -0400 (EDT)
Message-ID: <20120404.052617.987975279373275914.davem@davemloft.net>
References: <20120404121300.2e05437b@pixies.home.jungo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: shmulik.ladkani@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120404121300.2e05437b@pixies.home.jungo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Wed, 4 Apr 2012 12:13:00 +0300

> In 72331bc [ipv6: Fix RTM_GETROUTE's interpretation of RTA_IIF to be
> consistent with ipv4] the code of 'inet6_rtm_getroute()' was re-ordered
> such that the reference to 'rt->dst' is incremented prior skb
> allocation.
> 
> Hence, if 'alloc_skb()' fails, must drop a reference from 'rt->dst'.
> Add the missing 'dst_release()' call.
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied, thanks.
