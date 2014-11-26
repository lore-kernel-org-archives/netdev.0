From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/5] ethernet/intel: Use eth_skb_pad helper
Date: Tue, 25 Nov 2014 22:19:00 -0500 (EST)
Message-ID: <20141125.221900.653470310152197801.davem@davemloft.net>
References: <1416957251.29427.39.camel@edumazet-glaptop2.roam.corp.google.com>
	<54752263.2040204@gmail.com>
	<1416966185.29427.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbaKZDTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 22:19:06 -0500
In-Reply-To: <1416966185.29427.46.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Nov 2014 17:43:05 -0800

> I believe I finally have an idea why we had various + 15 in skb
> allocations in TCP stack !

It was so that you could do one level of tunneling with "for
free".  Or that is my recollection.

Those + 15 existed way before any of these padto() calls even
existed.
