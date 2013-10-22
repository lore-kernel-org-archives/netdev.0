From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netpoll: linearize skb before accessing its data
Date: Tue, 22 Oct 2013 02:50:38 -0400 (EDT)
Message-ID: <20131022.025038.1046903740187748879.davem@davemloft.net>
References: <20131022060635.GF1544@neomailbox.net>
	<20131022.022525.2068838304168924147.davem@davemloft.net>
	<20131022063714.GI1544@neomailbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868Ab3JVGuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 02:50:40 -0400
In-Reply-To: <20131022063714.GI1544@neomailbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Tue, 22 Oct 2013 08:37:14 +0200

> Ok I will do that. But I think this API change must go into
> net-next, right?  Otherwise we would break every existing user.

Too bad, it's a necessary API change to fix the bug, the users
will need to change too.

It's not our problem if they are out-of-tree and can't be fixed
in-situ.
