From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 00/29] Phase 2 of fib_trie updates
Date: Fri, 27 Feb 2015 16:01:17 -0500 (EST)
Message-ID: <20150227.160117.1055227896487065510.davem@davemloft.net>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
	<20150224.225300.107506639649235664.davem@davemloft.net>
	<54ED59D0.9010401@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754632AbbB0VBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 16:01:19 -0500
In-Reply-To: <54ED59D0.9010401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 24 Feb 2015 21:12:48 -0800

> The problem is that the tnodes are now split over 2 cache lines.  As a
> result in order to resize a node, or replace it with the leaf contained
> in the node you end up having to replace the parent of the node as well. 

Therefore I still think that batching the rebalancing across all of the
per-device address removals will help a lot here.

This is true with or without your fib_trie modifications.
