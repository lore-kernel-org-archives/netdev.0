From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-V
Date: Thu, 17 Sep 2015 11:52:18 -0700 (PDT)
Message-ID: <20150917.115218.655587837796826886.davem@davemloft.net>
References: <BY2PR0301MB16540426BFD633C8EBD1A4BBA05B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CB989E9@AcuExch.aculab.com>
	<BY2PR0301MB16547020327B59C72692E730A05A0@BY2PR0301MB1654.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, alexander.duyck@gmail.com,
	haiyangz@microsoft.com, vkuznets@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jasowang@redhat.com
To: kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbbIQSwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 14:52:20 -0400
In-Reply-To: <BY2PR0301MB16547020327B59C72692E730A05A0@BY2PR0301MB1654.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: KY Srinivasan <kys@microsoft.com>
Date: Thu, 17 Sep 2015 15:14:05 +0000

> I think I can achieve my original goal of not having any allocation
> in the send path by carefully using the memory available in the skb:

Please stop flat-out ignoring David L.'s suggestion.

Have a pre-cooked ring of buffers for these descriptors that you can
point the chip at.  No per-packet allocation is necessary at all.

If you play games with SKBs you will get burned.
