From: David Miller <davem@davemloft.net>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Fri, 24 Jun 2011 13:27:54 -0700 (PDT)
Message-ID: <20110624.132754.1342293081627931354.davem@davemloft.net>
References: <4E04D59B.8060301@goop.org>
	<20110624.124624.1329947216240823992.davem@davemloft.net>
	<4E04EF8F.6070900@goop.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, Ian.Campbell@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	rusty@rustcorp.com.au
To: jeremy@goop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403Ab1FXUaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 16:30:08 -0400
In-Reply-To: <4E04EF8F.6070900@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Fri, 24 Jun 2011 13:11:59 -0700

> Are the pages still attached to the first skb, or are they transferred
> completely?

In this case they are transferred completely, the refcount isn't
modified at all.

There are cases where partial transfers occur, and in such cases
the refcount is modified.  Just swim around in net/core/skbuff.c
you'll find them :-)


