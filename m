From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 1/2] rhashtable: unconditionally grow when max_shift
 is not specified
Date: Wed, 25 Feb 2015 16:28:46 +0000
Message-ID: <20150225162846.GA13107@casper.infradead.org>
References: <cover.1424877322.git.daniel@iogearbox.net>
 <0973a6e9b73a2ca14477c0cf98093d5f1b3d3d40.1424877322.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, pablo@netfilter.org, johunt@akamai.com,
	kaber@trash.net, netdev@vger.kernel.org,
	Ying Xue <ying.xue@windriver.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52215 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbbBYQ2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 11:28:52 -0500
Content-Disposition: inline
In-Reply-To: <0973a6e9b73a2ca14477c0cf98093d5f1b3d3d40.1424877322.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/15 at 04:31pm, Daniel Borkmann wrote:
> diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
> index 58b9953..f9e9d73 100644
> --- a/lib/test_rhashtable.c
> +++ b/lib/test_rhashtable.c
> @@ -202,8 +202,6 @@ static int __init test_rht_init(void)
>  		.key_len = sizeof(int),
>  		.hashfn = jhash,
>  		.nulls_base = (3U << RHT_BASE_SHIFT),
> -		.grow_decision = rht_grow_above_75,
> -		.shrink_decision = rht_shrink_below_30,
>  	};
>  	int err;

I assume you wanted this chunk in patch 2.
