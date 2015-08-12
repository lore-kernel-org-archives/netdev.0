From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Wed, 12 Aug 2015 16:45:19 -0700 (PDT)
Message-ID: <20150812.164519.1783786478654950784.davem@davemloft.net>
References: <1439396033-6264-1-git-send-email-pdowney@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: pdowney@brocade.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439396033-6264-1-git-send-email-pdowney@brocade.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philip Downey <pdowney@brocade.com>
Date: Wed, 12 Aug 2015 17:13:53 +0100

> IGMP reports are generated for link local multicast groups (224.0.0.1
> - 224.0.0.255) used by the routing protocols such as RIP, OSPF etc.
> In general routers do not generate reports for local multicast groups.
> 
> IGMP reports for local multicast groups can now be inhibited by means
> of a system control variable (setting the value to zero).
> 
> To retain backwards compatibility the previous behaviour is retained by
> default on system boot.
> 
> Signed-off-by: Philip Downey <pdowney@brocade.com>

I'm always hesitent to apply patches like this.

I can't even understand from your explanation:

1) what about local reporting behavior is so bad

2) why you want to inhibit them at all

For example, this:

> In general routers do not generate reports for local multicast groups.

Doesn't tell me anything.  You need to go into more detail about
this, and explain the situation sufficiently.
