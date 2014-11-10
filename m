From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Remove unnecessary struct in6_addr *
 casts
Date: Mon, 10 Nov 2014 14:09:23 -0500 (EST)
Message-ID: <20141110.140923.1795637220425531256.davem@davemloft.net>
References: <1415335574.23530.4.camel@perches.com>
	<20141110.132837.1817456437352515704.davem@davemloft.net>
	<1415645298.8868.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org, leedom@chelsio.com,
	anish@chelsio.com, praveenm@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbaKJTJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 14:09:28 -0500
In-Reply-To: <1415645298.8868.10.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 10 Nov 2014 10:48:18 -0800

> btw: using "git format-patch -M" makes reading and
> verifying the patch a lot easier.
> 
> Unfortunately, there's no current way to make this
> a global default for everyone, but I have this in
> my ~/.gitconfig:

None of those moves were pure moves, I adjusted the top-level
cpp guard names in every file plus there were some path changes
in net/bonding.h as well.
