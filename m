From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] inetpeer: add namespace support for
 inetpeer
Date: Thu, 07 Jun 2012 20:53:48 -0700 (PDT)
Message-ID: <20120607.205348.913373847915721607.davem@davemloft.net>
References: <20120606.104323.1698446129331745479.davem@davemloft.net>
	<20120607.144301.1259354794384347085.davem@davemloft.net>
	<4FD158E4.1080701@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: serge.hallyn@canonical.com, ebiederm@xmission.com,
	herbert@gondor.apana.org.au, steffen.klassert@secunet.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754285Ab2FHDxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 23:53:52 -0400
In-Reply-To: <4FD158E4.1080701@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Fri, 08 Jun 2012 09:44:04 +0800

> Sorry for my pool english, I don't understand this.
> Can you explain it for me?

Look at the end of the parts of the patch that change
net/ipv4/inetpeer.c:

@@ -586,3 +617,3 @@  out:
 	write_sequnlock_bh(&base->lock);
 }
 EXPORT_SYMBOL(inetpeer_invalidate_tree);

That makes no sense, it's a patch hunk with no "+" or "-"
lines.

Your patch was corrupted by something.

This is extremely irritating.  I would recommend that you email
patches to yourself, and try to apply the copies you receive
in those emails.  Because that's what the people trying to use
your patch are going to do.
