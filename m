From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Sat, 28 Aug 2010 15:31:24 -0700
Message-ID: <20100828153124.0e76425f@nehalam>
References: <20100828143132.GA3211@del.dom.local>
	<1283006909.2277.22.camel@edumazet-laptop>
	<20100828101424.69c4c782@s6510>
	<20100828.144130.189711704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jarkao2@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43426 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299Ab0H1Wb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Aug 2010 18:31:26 -0400
In-Reply-To: <20100828.144130.189711704.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Aug 2010 14:41:30 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> Since netpoll does similar things, this means both NAPI and netpoll
> cannot function properly with SKY2's second port.  It will only work
> right on the first port.

I knew netpoll was broken on second port.

-- 
