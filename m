From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/3] fib_trie: move statistics to debugfs
Date: Mon, 18 Feb 2008 08:49:56 -0800
Message-ID: <20080218084956.6bfd1127@extreme>
References: <20080213195805.493794050@vyatta.com>
	<20080213195929.781366896@vyatta.com>
	<20080217.222655.262637827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:39643 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750770AbYBRQuA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 11:50:00 -0500
In-Reply-To: <20080217.222655.262637827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 17 Feb 2008 22:26:55 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 13 Feb 2008 11:58:06 -0800
> 
> > Don't want /proc/net/fib_trie and /proc/net/fib_triestat to become
> > permanent kernel space ABI issues, so move to the safer confines of debugfs.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Stephen, the cat is already out of the bag.  We already export this
> thing so if you want to export different stuff you'll have to provide
> it via some other means, somewhere else.
> 
> Thanks.

Are we stuck with the format problems?
  * crappy tree printout
  * not printing other tables
