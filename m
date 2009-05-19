From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: gen_estimator: use 64 bits intermediate
 counters for bps
Date: Tue, 19 May 2009 01:18:38 -0700 (PDT)
Message-ID: <20090519.011838.08723886.davem@davemloft.net>
References: <4A11F67B.3050805@cosmosbay.com>
	<20090519070252.GA4210@ff.dom.local>
	<4A126058.7030605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, vexwek@gmail.com, netdev@vger.kernel.org,
	kaber@trash.net, devik@cdi.cz
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55790
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750898AbZESISk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 04:18:40 -0400
In-Reply-To: <4A126058.7030605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 19 May 2009 09:31:36 +0200

> Apparently gcc does the *right* thing on x86_32, but we probably
> want something stronger here. I could not find gcc documentation
> statement on right shifts of negative values.

It emits an "arithmetic shift right" for every CPU I've ever checked.
