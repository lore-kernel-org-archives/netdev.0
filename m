From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] fib_trie: move statistics to debugfs
Date: Sun, 17 Feb 2008 22:26:55 -0800 (PST)
Message-ID: <20080217.222655.262637827.davem@davemloft.net>
References: <20080213195805.493794050@vyatta.com>
	<20080213195929.781366896@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40242
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751666AbYBRG0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 01:26:18 -0500
In-Reply-To: <20080213195929.781366896@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 13 Feb 2008 11:58:06 -0800

> Don't want /proc/net/fib_trie and /proc/net/fib_triestat to become
> permanent kernel space ABI issues, so move to the safer confines of debugfs.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Stephen, the cat is already out of the bag.  We already export this
thing so if you want to export different stuff you'll have to provide
it via some other means, somewhere else.

Thanks.
