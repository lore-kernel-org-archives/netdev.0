From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: icmp: Fix pMTU handling for rare case
Date: Tue, 01 Jul 2014 11:05:10 -0700 (PDT)
Message-ID: <20140701.110510.2218293817137911715.davem@davemloft.net>
References: <1404141362-21015-1-git-send-email-edward.allcutt@openmarket.com>
	<20140630.234843.985671994258957329.davem@davemloft.net>
	<alpine.DEB.2.10.1407010937120.5997@tabini.allcutt.me.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: edward.allcutt@openmarket.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1407010937120.5997@tabini.allcutt.me.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Edward Allcutt <edward.allcutt@openmarket.com>
Date: Tue, 1 Jul 2014 09:42:14 +0100 (BST)

> If it helps any, I've been running several production machines with
> this patch for just about a year now (mostly running 3.10 stable
> series).

I guess if OpenBSD can wait more than 2 decades to implement proper
path mtu handling, you can wait a year to post this bug fix :-)

I still think the OpenBSD thing can't be intentional, and it's some
bug they probably want to fix and it should therefore be investigated.
It means performance of connections going through such machines is
going to be crap even if I install your patch.
