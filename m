From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: propagate gso_min_segs
Date: Wed, 23 Mar 2016 14:25:56 -0400 (EDT)
Message-ID: <20160323.142556.2023977823696366302.davem@davemloft.net>
References: <1458696914-16088-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
	<1458700432.10868.32.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanhaishuang@cmss.chinamobile.com, kaber@trash.net,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458700432.10868.32.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Mar 2016 19:33:52 -0700

> On Wed, 2016-03-23 at 09:35 +0800, Haishuang Yan wrote:
>> vlan drivers lack proper propagation of gso_min_segs from lower device.
>> 
>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>> ---
> 
> The plan was to get rid of gso_min_segs, as nothing uses it.
> 
> Otherwise I would have included this in my recent patches...
> 
> For such a rare 'issue' , we believe ndo_features_check() is better,
> because it does not slow down the fast path.

I'm not aplpying this.
