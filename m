From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/7] sctp: Add GSO support
Date: Fri, 03 Jun 2016 19:37:50 -0400 (EDT)
Message-ID: <20160603.193750.2212448136295973014.davem@davemloft.net>
References: <cover.1464888549.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	lucien.xin@gmail.com, nhorman@tuxdriver.com,
	David.Laight@ACULAB.COM, vyasevich@gmail.com,
	alexander.duyck@gmail.com, daniel@iogearbox.net, fw@strlen.de,
	eric.dumazet@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbcFCXhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 19:37:53 -0400
In-Reply-To: <cover.1464888549.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Thu,  2 Jun 2016 15:05:37 -0300

> This patchset adds sctp GSO support.
> 
> Performance tests indicates that increases throughput by 10% if using
> bigger chunk sizes, specially if bigger than MTU. For small chunks, it
> doesn't help much if not using heavy firewall rules.
> 
> For small chunks it will probably be of more use once we get something
> like MSG_MORE as David Laight had suggested.
> 
> overall changes:
> v1->v2:
> Added support for receiving GSO frames on SCTP stack, as requested by
> Dave Miller.
> 
> v2->v3:
> Consider sctphdr size in skb_gso_transport_seglen()
> rebased due to 5c7cdf339af5 ("gso: Remove arbitrary checks for
> unsupported GSO")

Series applied, thanks Marcelo.
