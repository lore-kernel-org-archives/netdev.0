From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Improve MTU estimation
Date: Fri, 04 Aug 2006 13:21:32 +0200
Message-ID: <44D32DBC.8070607@trash.net>
References: <44D30A48.4050403@trash.net> <44D312EF.8010202@trash.net> <20060804100121.GA17239@gondor.apana.org.au> <44D31CCE.7020301@trash.net> <20060804101345.GA17583@gondor.apana.org.au> <44D32B57.2000304@trash.net> <20060804111604.GA25693@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:17365 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932479AbWHDLXZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 07:23:25 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060804111604.GA25693@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Aug 04, 2006 at 01:11:19PM +0200, Patrick McHardy wrote:
> 
>>>Of course it gets hairier if you have ESP padding.  I'm not even sure
>>>if the current code gets that right.
>>
>>Unless I'm missing something, the padding caused by IP options
>>is always less than the worst case that can happen anyway
>>(max(block size, padlen)-1), so it can simply be ignored.
> 
> 
> Are you talking about the ESP padding case, or transport mode in
> general?

Transport mode in general.

