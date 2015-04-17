From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: deinline net_generic()
Date: Fri, 17 Apr 2015 14:55:59 -0400 (EDT)
Message-ID: <20150417.145559.1979062479640998368.davem@davemloft.net>
References: <1429187895.7346.195.camel@edumazet-glaptop2.roam.corp.google.com>
	<55313D4D.4050402@redhat.com>
	<1429292536.7346.248.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvlasenk@redhat.com, ebiederm@xmission.com, jengelh@medozas.de,
	jpirko@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429292536.7346.248.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 Apr 2015 10:42:16 -0700

> On Fri, 2015-04-17 at 19:05 +0200, Denys Vlasenko wrote:
> 
>> How do you expect one to find excessively large inlines,
>> if not on allyesconfig build?
> 
> Tuning kernel sources based on allyesconfig build _size_ only is
> terrible. We could build an interpreter based kernel and maybe reduce
> its size by 50% who knows...
> 
> You are saying that all inline should be removed, since it is obvious
> kernel size _will_ be smaller.

+1
