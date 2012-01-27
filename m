From: David Miller <davem@davemloft.net>
Subject: Re: [v3.3-rc1 regression] TCP: too many of orphaned sockets
Date: Fri, 27 Jan 2012 16:28:23 -0500 (EST)
Message-ID: <20120127.162823.1960229872591588915.davem@davemloft.net>
References: <20120127142246.GA22318@elte.hu>
	<4F22B634.2020007@parallels.com>
	<4F22D05A.8030604@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: glommer@parallels.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F22D05A.8030604@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Glauber Costa <glommer@parallels.com>
Date: Fri, 27 Jan 2012 20:27:06 +0400

> +extern void init_tcp_mem(struct net *net);

Please name this "tcp_init_mem" or similar, keeping all TCP functions
globally exported with a "tcp_*" prefix.
