From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] bridge: ageing timer regression fix
Date: Fri, 11 Mar 2016 15:04:48 -0500 (EST)
Message-ID: <20160311.150448.895454572947313792.davem@davemloft.net>
References: <1457470775-32224-1-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932436AbcCKUEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 15:04:50 -0500
In-Reply-To: <1457470775-32224-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue,  8 Mar 2016 12:59:32 -0800

> This fixes regression in how ageing timer is managed.
> Backing out the change required fixing switch drivers as well.

Series applied, thanks.

Jiri, since I applied this to net-next, I had to deal with the conflicts
created by your world splitup of the rocker driver.  I wasn't sure, while
doing so, whether you'd like this new ageing_time member to remain in the
rocker struct, as in Stephen's patch, or to be placed in the ofdpa struct.
I choose the former, send me a patch if you want the latter.

I'll queue this up for -stable, as well.
