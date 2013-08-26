From: David Miller <davem@davemloft.net>
Subject: Re: sendto() bug?
Date: Mon, 26 Aug 2013 16:15:19 -0400 (EDT)
Message-ID: <20130826.161519.800608483815988746.davem@davemloft.net>
References: <alpine.DEB.2.02.1308231257140.10771@optio.utah.ind.alcatel.com>
	<alpine.LFD.2.00.1308241105220.1641@ja.ssi.bg>
	<alpine.DEB.2.02.1308261319370.23968@optio.utah.ind.alcatel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: chris.clark@alcatel-lucent.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852Ab3HZUPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 16:15:21 -0400
In-Reply-To: <alpine.DEB.2.02.1308261319370.23968@optio.utah.ind.alcatel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Clark <chris.clark@alcatel-lucent.com>
Date: Mon, 26 Aug 2013 14:14:21 -0600 (MDT)

> On Sat, 24 Aug 2013, Julian Anastasov wrote:
>> On Fri, 23 Aug 2013, Chris Clark wrote:
>> > In the same vein as 2ad5b9e4, I'm soliciting feedback on something
>> > similar for raw_sendmsg():
> [snip]
> 
>> 	So, something like
>> (inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0) ?
> 
> 
> Many thanks.  This patch indeed appears to resolve the problem:

Someone please submit this properly with a clean, well formed, commit
message and signoffs.

Thanks.
