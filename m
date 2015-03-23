From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netfilter: preparatory patches for set extensions
Date: Mon, 23 Mar 2015 16:44:18 -0400 (EDT)
Message-ID: <20150323.164418.1520100994652735634.davem@davemloft.net>
References: <1426952290-18962-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, herbert@gondor.apana.org.au, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbbCWUoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 16:44:20 -0400
In-Reply-To: <1426952290-18962-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 21 Mar 2015 15:38:08 +0000

> These patches contain some prepraration for nftables set extensions.
> These extensions will allow to attach dynamically sized data to set
> elements, thereby moving the key to a non-fixed position.
> 
> This requires nft_hash to use the rhashtable callbacks. Since the
> key length is variable, the length must be provided to the obj_hashfn.
> 
> The patches change rhashtable to do so and do a conversion of nft_hash
> to rhashtable callbacks without any functional changes.
> 
> @Dave and Pablo: these patches apply on top of nf-next and a bunch
> of patches I just sent to Pablo, but also need Herbert's recent
> changes in net-next. Additionally I have more patches coming up
> which depend on these changes. In order to simplify things, I'd
> suggest to have the rhashtable change go through Pablo's tree if
> you don't mind.

Pablo can take this stuff, no problem.
