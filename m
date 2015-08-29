From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: mmap: fix lookup frame position
Date: Fri, 28 Aug 2015 22:26:03 -0700 (PDT)
Message-ID: <20150828.222603.1259346863370445309.davem@davemloft.net>
References: <20150825.201712.2151042716686513603.davem@davemloft.net>
	<20150828070058.GA32596@gmail.com>
	<20150828070520.GB32596@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, fw@strlen.de
To: chamaken@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58268 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbbH2F0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 01:26:04 -0400
In-Reply-To: <20150828070520.GB32596@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Date: Fri, 28 Aug 2015 16:05:20 +0900

> __netlink_lookup_frame() was always called with the same "pos"
> value in netlink_forward_ring(). It will look at the same ring entry
> header over and over again, every time through this loop. Then cycle
> through the whole ring, advancing ring->head, not "pos" until it
> equals the "ring->head != head" loop test fails.
> 
> Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>

Applied.
