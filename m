From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Fri, 10 Jan 2014 00:00:15 -0500 (EST)
Message-ID: <20140110.000015.894651173788124077.davem@davemloft.net>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbaAJFAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 00:00:19 -0500
In-Reply-To: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 9 Jan 2014 20:54:09 -0800 (PST)

> When initializing a gro_list for a packet, first check the rxhash of
> the incoming skb against that of the skb's in the list. This should be
> a very strong inidicator of whether the flow is going to be matched,
> and potentially allows a lot of other checks to be short circuited.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

This is not appropriate for 'net', so I assume you mean to target
this for 'net-next', right?
