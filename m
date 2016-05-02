From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] sctp: Add GSO support
Date: Mon, 02 May 2016 19:16:14 -0400 (EDT)
Message-ID: <20160502.191614.608026435064266168.davem@davemloft.net>
References: <cover.1461965035.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, David.Laight@ACULAB.COM,
	alexander.duyck@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932232AbcEBXQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 19:16:19 -0400
In-Reply-To: <cover.1461965035.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 29 Apr 2016 18:33:31 -0300

> This patchset adds sctp GSO support.
> 
> Performance tests indicates that increases throughput by 10% if using
> bigger chunk sizes, specially if bigger than MTU. For small chunks, it
> doesn't help much if not using heavy firewall rules.
> 
> For small chunks it will probably be of more use once we get something
> like MSG_MORE as David Laight had suggested.
> 
> I believe I could address all comments from the RFC attempt.

Are these packets idempotent?

Ie. if we GRO a bunch of SCTP frames on receive and that GRO frame is
forwarded rather than received locally, is the same exact packet
stream emitted on transmit?
