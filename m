From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] dst: take into account policy update on check()
Date: Mon, 10 Sep 2012 15:10:39 +0200
Message-ID: <1347282639.1234.1569.camel@edumazet-glaptop>
References: <504A08EA.3080506@6wind.com>
	 <1347030598.2484.777.camel@edumazet-glaptop> <504A0F1F.5060504@6wind.com>
	 <20120907.144828.97793990734588625.davem@davemloft.net>
	 <504DE17A.1000908@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vyasevich@gmail.com,
	sri@us.ibm.com, linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63619 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102Ab2IJNKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 09:10:44 -0400
In-Reply-To: <504DE17A.1000908@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-10 at 14:47 +0200, Nicolas Dichtel wrote:

> So it means that IPv6 dst entries will be invalidated by IPv4 route management. 
> For example, calling rt_cache_flush() will flush IPv6 dst too. Is this acceptable?

If it can save another test in fast path, this is acceptable, yes.
