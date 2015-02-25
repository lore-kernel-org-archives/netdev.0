From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Wed, 25 Feb 2015 17:23:28 +0000
Message-ID: <20150225172328.GB18416@casper.infradead.org>
References: <cover.1424877322.git.daniel@iogearbox.net>
 <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, pablo@netfilter.org, johunt@akamai.com,
	kaber@trash.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52480 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbbBYRXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:23:30 -0500
Content-Disposition: inline
In-Reply-To: <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/15 at 04:31pm, Daniel Borkmann wrote:
> Currently, all real users of rhashtable default their grow and shrink
> decision functions to rht_grow_above_75() and rht_shrink_below_30(),
> so that there's currently no need to have this explicitly selectable.
> 
> It can/should be generic and private inside rhashtable until a real
> use case pops up. Since we can make this private, we'll save us this
> additional indirection layer and can improve insertion/deletion time
> as well.
> 
> Reference: http://patchwork.ozlabs.org/patch/443040/
> Suggested-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Nice

Acked-by: Thomas Graf <tgraf@suug.ch>
