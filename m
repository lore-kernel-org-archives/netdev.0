From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix pppol2tp getsockname()
Date: Tue, 20 Mar 2012 16:13:27 -0400 (EDT)
Message-ID: <20120320.161327.1634186044606581815.davem@davemloft.net>
References: <20120320135754.GA30155@kvack.org>
	<4F6898DE.4020508@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bcrl@kvack.org, netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752835Ab2CTUNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 16:13:35 -0400
In-Reply-To: <4F6898DE.4020508@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Tue, 20 Mar 2012 14:49:02 +0000

> On 20/03/12 13:57, Benjamin LaHaise wrote:
>> While testing L2TP functionality, I came across a bug in getsockname().  The
>> IP address returned within the pppol2tp_addr's addr memember was not being
>> set to the IP  address in use.  This bug is caused by using inet_sk() on the
>> wrong socket (the L2TP socket rather than the underlying UDP socket), and was
>> likely introduced during the addition of L2TPv3 support.
>> 
>> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied and queued up for -stable, thanks.
