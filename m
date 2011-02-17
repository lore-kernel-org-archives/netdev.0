From: David Miller <davem@davemloft.net>
Subject: Re: IGMP and rwlock: Dead ocurred again on TILEPro
Date: Thu, 17 Feb 2011 14:53:33 -0800 (PST)
Message-ID: <20110217.145333.232751283.davem@davemloft.net>
References: <20110217054237.GB2653@cr0.nay.redhat.com>
	<20110216.214625.189707123.davem@davemloft.net>
	<4D5DA60A.8080201@tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, cypher.w@gmail.com,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D5DA60A.8080201@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Thu, 17 Feb 2011 17:49:46 -0500

> The fix is to disable interrupts for the arch_read_lock family of methods. 

How does that help handle the race when it happens between different
cpus, instead of between IRQ and non-IRQ context on the same CPU?

Why don't you just use the generic spinlock based rwlock code on Tile,
since that is all that your atomic instructions can handle
sufficiently?
