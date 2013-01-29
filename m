From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/6] net: cacheline adjust struct inet_frags
 for better frag performance
Date: Mon, 28 Jan 2013 23:23:42 -0500 (EST)
Message-ID: <20130128.232342.399301649354832893.davem@davemloft.net>
References: <20130124140343.14119.77712.stgit@dragon>
	<20130124140417.14119.32738.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, amwang@redhat.com, kaber@trash.net,
	herbert@gondor.hengli.com.au, dborkman@redhat.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567Ab3A2EXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 23:23:44 -0500
In-Reply-To: <20130124140417.14119.32738.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 24 Jan 2013 15:04:20 +0100

> +	/* --- read-mostly cacheline boundary (was 24 bytes ago) --- */

This "24" is context dependent, I assume it applies to 64-bit builds
rather than 32-bit ones.

Either add the necessary details or just get rid of this part of the
comment altogether.
