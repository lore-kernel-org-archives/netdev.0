From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rps_dev_flow_table_release(): no need to delay vfree()
Date: Mon, 06 May 2013 11:08:51 -0400 (EDT)
Message-ID: <20130506.110851.2225186248333393414.davem@davemloft.net>
References: <20130506020346.GK25399@ZenIV.linux.org.uk>
	<20130506020555.GL25399@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001Ab3EFPIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 11:08:55 -0400
In-Reply-To: <20130506020555.GL25399@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Mon, 6 May 2013 03:05:55 +0100

> The same story as with fib_trie patch - vfree() from RCU callbacks
> is legitimate now.
>     
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Applied.
