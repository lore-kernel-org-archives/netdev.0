From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/5] sctp: add the rhashtable apis for sctp
 global transport hashtable
Date: Mon, 11 Jan 2016 16:35:43 -0500 (EST)
Message-ID: <20160111.163543.869963270978192882.davem@davemloft.net>
References: <20160111160039.GA6061@mrl.redhat.com>
	<5693E451.2000306@gmail.com>
	<20160111180927.GG6061@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, herbert@gondor.apana.org.au,
	lucien.xin@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, vyasevic@redhat.com,
	daniel@iogearbox.net
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758936AbcAKVfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 16:35:46 -0500
In-Reply-To: <20160111180927.GG6061@mrl.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: mleitner@redhat.com
Date: Mon, 11 Jan 2016 16:09:27 -0200

> There is still the other part of this thread to be worked on (re
> ->dead), maybe that will justify extra stuff in here but I really
> wouldn't like to add extra structures and locks on this just to satisfy
> an unreasonable scenario like this. This hash is very busy, the lean it
> is, the better.

It is never "unreasonable" if it is necessary to fix a real bug, which
this is.
