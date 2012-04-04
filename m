From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1] ipv6: Fix RTM_GETROUTE's interpretation of RTA_IIF
 to be consistent with ipv4
Date: Wed, 04 Apr 2012 03:54:14 -0400 (EDT)
Message-ID: <20120404.035414.765974934836327594.davem@davemloft.net>
References: <20120401170345.5ed75cab@pixies.home.jungo.com>
	<20120401.173032.1881937766187683052.davem@davemloft.net>
	<20120404105204.63122c38@pixies.home.jungo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: shmulik.ladkani@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120404105204.63122c38@pixies.home.jungo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Wed, 4 Apr 2012 10:52:04 +0300

> In case of 'alloc_skb' failure, shouldn't we issue a
> 'dst_release(&rt->dst)'?
> 
> If correct, I'll submit a fix. Should have spotted this earlier.

Yep, we need a release there.
