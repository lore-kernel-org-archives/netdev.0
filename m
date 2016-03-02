From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] mac80211: mesh: convert path table to rhashtable
Date: Wed, 02 Mar 2016 14:43:59 -0500 (EST)
Message-ID: <20160302.144359.2141637165742439224.davem@davemloft.net>
References: <1456931360-2846-1-git-send-email-me@bobcopeland.com>
	<1456931360-2846-2-git-send-email-me@bobcopeland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
	tgraf@suug.ch, netdev@vger.kernel.org
To: me@bobcopeland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbcCBToB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 14:44:01 -0500
In-Reply-To: <1456931360-2846-2-git-send-email-me@bobcopeland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bob Copeland <me@bobcopeland.com>
Date: Wed,  2 Mar 2016 10:09:20 -0500

> In the time since the mesh path table was implemented as an
> RCU-traversable, dynamically growing hash table, a generic RCU
> hashtable implementation was added to the kernel.
> 
> Switch the mesh path table over to rhashtable to remove some code
> and also gain some features like automatic shrinking.
> 
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Bob Copeland <me@bobcopeland.com>

Johannes, feel free to take both patches via your tree, thanks.
