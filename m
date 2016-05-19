From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: remove busylock
Date: Thu, 19 May 2016 11:12:08 -0700 (PDT)
Message-ID: <20160519.111208.1949769629804288508.davem@davemloft.net>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aduyck@mirantis.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755279AbcESSML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 14:12:11 -0400
In-Reply-To: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 May 2016 10:08:36 -0700

> busylock was added at the time we had expensive ticket spinlocks
> 
> (commit 79640a4ca6955e3ebdb7038508fa7a0cd7fa5527 ("net: add additional
> lock to qdisc to increase throughput")
> 
> Now kernel spinlocks are MCS, this busylock things is no longer
> relevant. It is slowing down things a bit.
 ...
> That would be a 8 % increase.

Presumably only for x86-64 and other platforms that actually are using
the ticket spinlocks.

For others it would be a regression.
