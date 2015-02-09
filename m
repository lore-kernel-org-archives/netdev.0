From: Thomas Graf <tgraf@suug.ch>
Subject: Re: nft hash set expansion problem
Date: Mon, 9 Feb 2015 15:21:27 +0000
Message-ID: <20150209152127.GA29739@casper.infradead.org>
References: <54D7BB53.2050203@akamai.com>
 <54D7E677.5050708@iogearbox.net>
 <54D8C7D0.9030803@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53602 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760919AbbBIPVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 10:21:30 -0500
Content-Disposition: inline
In-Reply-To: <54D8C7D0.9030803@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/09/15 at 08:44am, Josh Hunt wrote:
> On 02/08/2015 04:43 PM, Daniel Borkmann wrote:
> >This seems not correct as we want to have an upper limit for
> >rhashtable expansions. It's better to define a max_shift for
> >nftables, instead.
> 
> Thanks Daniel that's what I wanted to know. I'll fix this on the nft_hash
> side.

I agree it does not make sense to allow unlimited growth.
Can you enforce a max_shift > 0 in rhashtable_init() while you
are at it? 
