From: David Miller <davem@davemloft.net>
Subject: Re: vnet problem (bug? feature?)
Date: Mon, 16 Feb 2015 11:54:08 -0800 (PST)
Message-ID: <20150216.115408.999383132375922083.davem@davemloft.net>
References: <20150215190008.GA25792@faui40p.informatik.uni-erlangen.de>
	<CACP96tRBPy4cakmJY_K9zrYbgWLgNfxDo4inrH8qV6pgRtR-1g@mail.gmail.com>
	<20150216101309.GB25792@faui40p.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini05@gmail.com, billfink@mindspring.com,
	cwang@twopensource.com, netdev@vger.kernel.org
To: tte@cs.fau.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbbBPTq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 14:46:57 -0500
In-Reply-To: <20150216101309.GB25792@faui40p.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toerless Eckert <tte@cs.fau.de>
Date: Mon, 16 Feb 2015 11:13:10 +0100

> I fail to find a good reference explaining why linux would default to
> rp_filtering = 1 (more appropriate for routers) even if forwarding defaults to 0
> (more appropriate for multi-homed hosts). 
> 
> Any ideas how to track back where this  choice came from ? 

"Linux", ie. the kernel, does not default to '1' for rp_filtering.

The distributions are setting it to a non-zere value via
/etc/sysctl.conf or similar, and I've always said that I consider it
an extremely poor decision, as reverse path filtering is completely
pointless on an end host.
