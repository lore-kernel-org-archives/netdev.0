From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] [IPV4] fib_trie: Fix lookup error return
Date: Thu, 10 Jul 2008 10:54:50 -0700
Message-ID: <20080710105450.3ef6cd14@extreme>
References: <20080710132336.GO28029@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	William Boughton <bill@boughton.de>, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:49114 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755037AbYGJRy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 13:54:56 -0400
In-Reply-To: <20080710132336.GO28029@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Jul 2008 14:23:37 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> In commit a07f5f508a4d9728c8e57d7f66294bf5b254ff7f "[IPV4] fib_trie: style
> cleanup", the changes to check_leaf() and fn_trie_lookup() were wrong - where
> fn_trie_lookup() would previously return a negative error value from
> check_leaf(), it now returns 0.
>  
> Now fn_trie_lookup() doesn't appear to care about plen, so we can revert
> check_leaf() to returning the error value.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Tested-by: William Boughton <bill@boughton.de>

Acked-by: Stephen Heminger <shemminger@vyatta.com>
