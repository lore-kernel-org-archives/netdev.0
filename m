From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix pppol2tp getsockname()
Date: Mon, 19 Mar 2012 17:50:04 -0400 (EDT)
Message-ID: <20120319.175004.1208028273487447802.davem@davemloft.net>
References: <20120319031534.GC11293@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500Ab2CSVuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 17:50:13 -0400
In-Reply-To: <20120319031534.GC11293@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Sun, 18 Mar 2012 23:15:34 -0400

> 
> While testing L2TP functionality, I came across a bug in getsockname().  The
> IP address returned within the pppol2tp_addr's addr memember was not being
> set to the IP address in use.  This bug is caused by using inet_sk() on the
> wrong socket (the L2TP socket rather than the underlying UDP socket), and was
> likely introduced during the addition of L2TPv3 support.

Please resubmit this freshly with a proper signoff.
