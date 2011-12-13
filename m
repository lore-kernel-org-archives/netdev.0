From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: rtnl_link_register always returns zero
Date: Tue, 13 Dec 2011 16:08:10 -0500 (EST)
Message-ID: <20111213.160810.785264274549847462.davem@davemloft.net>
References: <1323808281-9967-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755359Ab1LMVI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 16:08:28 -0500
In-Reply-To: <1323808281-9967-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: alex.bluesman.smirnov@gmail.com
Date: Wed, 14 Dec 2011 00:31:21 +0400

> From: Alexander Smirnov <alexander@Lenovo.(none)>
> 
> Both functions 'rtnl_link_register' and '__rtnl_link_register' always
> return zero. So handling return status has no sense in several drivers.
> 
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

This is never acceptable.

As long as those routines do return a value we SHOULD NOT ignore
it.

If you ignore it, then if we do have to start returning an error
then all of these call sites have to be reverted back, which is
a waste of time.
