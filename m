From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove tests on 64bit platforms
Date: Mon, 24 Jan 2011 23:30:57 -0800 (PST)
Message-ID: <20110124.233057.115949202.davem@davemloft.net>
References: <1295929298-13163-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49986
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751599Ab1AYHaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 02:30:23 -0500
In-Reply-To: <1295929298-13163-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue, 25 Jan 2011 12:21:38 +0800

> On 64bit platforms, >31 bit shifting of a unsigned long variable is
> valid, so we can remove the related boundary tests, which may slow
> down the CPU if branch prediction fails.

The key word is "may", you don't actually know if this kind of
change actually matters for performance in practice.

I'm not applying this.
