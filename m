From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Date: Tue, 08 Aug 2006 22:53:55 -0700 (PDT)
Message-ID: <20060808.225355.78711315.davem@davemloft.net>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	<20060809054648.GD17446@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	phillips@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20611
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030499AbWHIFxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 01:53:54 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060809054648.GD17446@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 9 Aug 2006 09:46:48 +0400

> There is another approach for that - do not use slab allocator for
> network dataflow at all. It automatically has all you pros amd if
> implemented correctly can have a lot of additional usefull and
> high-performance features like full zero-copy and total fragmentation
> avoidance.

Free advertisement for your network tree allocator Evgeniy? :-)

