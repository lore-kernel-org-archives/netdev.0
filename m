From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/3] netpoll: add IPv6 support
Date: Mon, 07 Jan 2013 19:46:21 -0800 (PST)
Message-ID: <20130107.194621.1068055780988116658.davem@davemloft.net>
References: <1357543036-15492-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab3AHDqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 22:46:22 -0500
In-Reply-To: <1357543036-15492-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon,  7 Jan 2013 15:17:13 +0800

> v4: remove ndisc_parse_options(), ignore ICMP options there
>     make udp6_csum_init() inline so that we don't rely on IPV6=y
>     fix a conflict with Jiri's patchset

Where did I say to inline this function?

I said to put it into a seperate static library that gets
linked into the kernel statically, regardless of whether
IPV6 is 'm' or 'y'.

I've said this _3_ times and I'm really starting to get
frustrated with the fact that you can't seem to read what
I write.

What part of the "obj-y +=" rules in net/ipv6/Makefile
are you unable to see?
