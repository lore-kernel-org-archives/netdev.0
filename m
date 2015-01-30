From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/9] nftables: reject NFT_SET_ELEM_INTERVAL_END flag for
 non-interval sets
Date: Fri, 30 Jan 2015 17:55:26 +0000
Message-ID: <20150130175525.GA8670@acer.localdomain>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
 <1422603994-5836-3-git-send-email-kaber@trash.net>
 <20150130173107.GA9243@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, davem@davemloft.net,
	David.Laight@ACULAB.COM, ying.xue@windriver.com,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38729 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbbA3Rzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 12:55:32 -0500
Content-Disposition: inline
In-Reply-To: <20150130173107.GA9243@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.01, Pablo Neira Ayuso wrote:
> Hi Patrick,
> 
> Unless you have any concern, I'm going to apply this and 8/9 to
> nf-next, so you don't need to resend these two sanitization fixes.

This one is not needed for mainline so far since nft_hash validates
on its own. It is only required since my series centralizes that
validation once the set extensions are added.

For 8/9, sure.
