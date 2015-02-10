From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/3] rhashtable: require max_shift definition
Date: Tue, 10 Feb 2015 00:58:01 +0000
Message-ID: <20150210005801.GA8951@casper.infradead.org>
References: <1423529311-26050-1-git-send-email-johunt@akamai.com>
 <1423529311-26050-2-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56313 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756110AbbBJA6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 19:58:04 -0500
Content-Disposition: inline
In-Reply-To: <1423529311-26050-2-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/09/15 at 07:48pm, Josh Hunt wrote:
>  	if ((params->key_len && !params->hashfn) ||
> -	    (!params->key_len && !params->obj_hashfn))
> +	    (!params->key_len && !params->obj_hashfn) ||
> +	    (!params->max_shift))
>  		return -EINVAL;

You can drop the parenthesis around the new max_shift check.

Other than that:

Acked-by: Thomas Graf <tgraf@suug.ch>
