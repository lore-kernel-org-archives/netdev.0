From: David Miller <davem@davemloft.net>
Subject: Re: net/netfilter/nf_conntrack_proto_tcp.c:1606:9: error:
 =?iso-8859-7?B?oXN0cnVjdCBuZl9wcm90b19uZXSi?= has no member named
 =?iso-8859-7?B?oXVzZXKi?=
Date: Mon, 11 Jun 2012 15:23:44 -0700 (PDT)
Message-ID: <20120611.152344.1072167705198124284.davem@davemloft.net>
References: <4fd664de.oQN9NTKjdledtla0%wfg@linux.intel.com>
	<20120611221521.GA27239@1984>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfg@linux.intel.com, gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513Ab2FKWXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 18:23:47 -0400
In-Reply-To: <20120611221521.GA27239@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 12 Jun 2012 00:15:21 +0200

> Could you please apply the following patch to net-next to resolve
> this? Thanks.

Applied, but you have to be kidding me with those ifdefs.

This is exactly the same kind of thing Gao suggested for
the inetpeer code recently and which I flat out rejected.

You can't pepper foo.c files with ifdefs all over the place.
