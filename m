From: David Miller <davem@davemloft.net>
Subject: Re: AF_PACKET mmap() v4...
Date: Thu, 05 Nov 2015 10:32:13 -0500 (EST)
Message-ID: <20151105.103213.2242523229143446058.davem@davemloft.net>
References: <20151105.000414.1682124328670738318.davem@davemloft.net>
	<AECBA5BB-2284-4C1E-ADCC-09B730D6EF9A@alum.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: guy@alum.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031333AbbKEPcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 10:32:15 -0500
In-Reply-To: <AECBA5BB-2284-4C1E-ADCC-09B730D6EF9A@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guy Harris <guy@alum.mit.edu>
Date: Thu, 5 Nov 2015 00:14:51 -0800

> As a core libpcap developer, I will at least state that it works a
> *lot* better than v1 and v2 did.  Having buffer slots that can hold
> only one packet is *really* suboptimal for packet capture; having
> buffer slots that can hold multiple packets works a lot better, as
> there's less wasted memory.

No doubt.

> I'll see whether there are any changes that *would* make libpcap's life better.

Thanks.
