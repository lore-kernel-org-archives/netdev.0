From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] infiniband: convert to use
 netdev_for_each_mc_addr
Date: Sat, 27 Feb 2010 02:44:42 -0800 (PST)
Message-ID: <20100227.024442.40098463.davem@davemloft.net>
References: <20100225084915.GA3171@psychotron.redhat.com>
	<20100227060146.GA13231@obsidianresearch.com>
	<20100227103835.GA2862@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgunthorpe@obsidianresearch.com, ogerlitz@voltaire.com,
	netdev@vger.kernel.org, linux-rdma@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41745
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965301Ab0B0KoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 05:44:24 -0500
In-Reply-To: <20100227103835.GA2862@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 27 Feb 2010 11:38:37 +0100

> I see two solutions:
> 1) check the length in all drivers to ensure correctness.
> 2) when bonding changes it's type, flush mc addresses and start over.
> 
> Second option looks nicer to me, but I might be missing something, thouths?

If bonding is causing this problem, perhaps we should make bonding
go through a programmatic interface to do it's work so that the
check can be done generically and in a place that will get
caught during code changes and audits.
