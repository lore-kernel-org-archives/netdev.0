From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 11:41:29 -0800 (PST)
Message-ID: <20160129.114129.2019628668155435035.davem@davemloft.net>
References: <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160129.110634.1678121731419241040.davem@davemloft.net>
	<1454096250.7627.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39253 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753439AbcA2Tlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 14:41:35 -0500
In-Reply-To: <1454096250.7627.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Jan 2016 11:37:30 -0800

> But really adding unaligned() accesses in flow dissector would slow it
> quite a lot on MIPS and others.

Agreed, the fix definitely belongs in the callers of these interfaces,
which in this case is the driver.
