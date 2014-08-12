From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: don't allow syn packets without timestamps to
 pass tcp_tw_recycle logic
Date: Mon, 11 Aug 2014 20:08:07 -0700 (PDT)
Message-ID: <20140811.200807.1174604291924802129.davem@davemloft.net>
References: <69ff43477a795a1117302b11583bc8ea8c5dc811.1407802666.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207AbaHLDIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 23:08:10 -0400
In-Reply-To: <69ff43477a795a1117302b11583bc8ea8c5dc811.1407802666.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 12 Aug 2014 02:21:36 +0200

> Thus this broken situation could easily arise by a Linux and Windows
> box sharing one IP address and talking to a tcp_tw_recycle enabled
> server.

As Eric Dumazet mentioned, timewait recycling does not work if any
traffic goes through a NAT box.

So this situation of two boxes "sharing one IP address" fundamentally
makes timewait recycling unusable.
