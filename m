From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/6] rhashtable: Use a single bucket lock for sibling
 buckets
Date: Sat, 31 Jan 2015 08:41:27 +0000
Message-ID: <20150131084127.GA13841@casper.infradead.org>
References: <14d537500868b4ff0396168cf9d5db95d327c128.1422576760.git.tgraf@suug.ch>
 <20150131043436.GA27564@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ying.xue@windriver.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40934 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbbAaIlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 03:41:32 -0500
Content-Disposition: inline
In-Reply-To: <20150131043436.GA27564@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/15 at 03:34pm, Herbert Xu wrote:
> Thomas, could you please hold off on these changes? They totally
> conflict with my rehash work, which is going to render these changes
> moot anyway since it'll completely change how expansion/shrinking
> works.

Can you share that work?
