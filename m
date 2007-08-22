From: Adrian Bunk <bunk@kernel.org>
Subject: Re: net/ipv4/fib_trie.c - compile error (Re: 2.6.23-rc3-mm1)
Date: Wed, 22 Aug 2007 17:41:11 +0200
Message-ID: <20070822154111.GI30705@stusta.de>
References: <20070822020648.5ea3a612.akpm@linux-foundation.org> <46CC5685.7090500@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Gabriel C <nix.or.die@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:40025 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761110AbXHVPmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 11:42:11 -0400
Content-Disposition: inline
In-Reply-To: <46CC5685.7090500@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 22, 2007 at 05:30:13PM +0200, Gabriel C wrote:
> Got it with a randconfig ( http://194.231.229.228/kernel/mm/2.6.23-rc3-mm1/r/randconfig-8 )
> 
> ...
> 
> net/ipv4/fib_trie.c: In function 'trie_rebalance':
> net/ipv4/fib_trie.c:969: error: lvalue required as unary '&' operand
> net/ipv4/fib_trie.c:971: error: lvalue required as unary '&' operand
> net/ipv4/fib_trie.c:977: error: lvalue required as unary '&' operand
> net/ipv4/fib_trie.c:980: error: lvalue required as unary '&' operand
>...

Side effect of the git-net removal, temporarily removing 
immunize-rcu_dereference-against-crazy-compiler-writers.patch should 
work around it.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

