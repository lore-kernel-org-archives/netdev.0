From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 1/2] rhashtable: unconditionally grow when max_shift
 is not specified
Date: Wed, 25 Feb 2015 17:09:38 +0000
Message-ID: <20150225170938.GA18416@casper.infradead.org>
References: <cover.1424877322.git.daniel@iogearbox.net>
 <0973a6e9b73a2ca14477c0cf98093d5f1b3d3d40.1424877322.git.daniel@iogearbox.net>
 <20150225162846.GA13107@casper.infradead.org>
 <54EDFA16.20308@iogearbox.net>
 <54EDFC02.2070206@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, pablo@netfilter.org, johunt@akamai.com,
	kaber@trash.net, netdev@vger.kernel.org,
	Ying Xue <ying.xue@windriver.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52408 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbbBYRJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:09:42 -0500
Content-Disposition: inline
In-Reply-To: <54EDFC02.2070206@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/15 at 05:44pm, Daniel Borkmann wrote:
> Note, the reason of this exercise is, because the semantics of
> max_shift == 0 have changed. A resize on inserts _before_ this
> change was impossible, now it becomes possible, so we have to
> disallow resizes (only) for the test case module specifically.

OK, I see what you are doing here. I will work on an improved
test case with parallel resizes after Herbert's rehashing.

Acked-by: Thomas Graf <tgraf@suug.ch>
