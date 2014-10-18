From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix a potential use after free in sit.c
Date: Sat, 18 Oct 2014 13:36:05 -0400 (EDT)
Message-ID: <20141018.133605.926101771002923562.davem@davemloft.net>
References: <1413647540.27176.36.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141018.130720.448065424567018228.davem@davemloft.net>
	<CAA93jw7qxXCSkWc4YRyiAJ9bwQnk4PwYX8eKfwZyZ2qnhM7QYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, roy.qing.li@gmail.com,
	netdev@vger.kernel.org, ghorbel@pivasoftware.com
To: dave.taht@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbaJRRgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 13:36:07 -0400
In-Reply-To: <CAA93jw7qxXCSkWc4YRyiAJ9bwQnk4PwYX8eKfwZyZ2qnhM7QYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Taht <dave.taht@gmail.com>
Date: Sat, 18 Oct 2014 10:22:35 -0700

> So far as I know, the one machine linux has never been ported
> to was a LISP machine. With its 36 bit words, and tagging, that
> would do what you want. I had kind of hoped with 64 bits of
> addressing some of those ideas would have been reused.
> 
> /me misses truly oddball architectures

Sparc cpus have tagged add and subtract instructions. :)
