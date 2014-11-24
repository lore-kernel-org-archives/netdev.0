From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rhashtable: Check for count mismatch while
 iterating in selftest
Date: Mon, 24 Nov 2014 16:17:44 -0500 (EST)
Message-ID: <20141124.161744.578588494163013973.davem@davemloft.net>
References: <20668a4b2ff01138f5b1d5b3b59650790e504c00.1416828807.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbaKXVRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 16:17:46 -0500
In-Reply-To: <20668a4b2ff01138f5b1d5b3b59650790e504c00.1416828807.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 24 Nov 2014 12:37:58 +0100

> Verify whether both the lock and RCU protected iterators see all
> test entries before and after expanding and shrinking has been
> performed. Also verify whether the number of entries in the hashtable
> remains stable during expansion and shrinking.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
