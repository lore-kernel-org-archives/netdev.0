From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 3/5] Network Drop Monitor: Adding kfree_skb_clean for
 non-drops and modifying end-of-line points for skbs
Date: Wed, 04 Mar 2009 14:47:22 -0800 (PST)
Message-ID: <20090304.144722.167821808.davem@davemloft.net>
References: <20090304161335.GC6392@ghostprotocols.net>
	<20090304.130614.127792905.davem@davemloft.net>
	<20090304224505.GD6392@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35973
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752844AbZCDWrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 17:47:37 -0500
In-Reply-To: <20090304224505.GD6392@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 4 Mar 2009 19:45:05 -0300

> hasta_la_vista_skbaby()

This is my personal favorite, it's very Mexifornia.

> consumed_skb()

But more seriously I like something like "consume_skb()" the best (ie.
drop the 'd').  It has the implication that an application or other
entity "consumed" and used the data before we freed the SKB.

What do you think?
