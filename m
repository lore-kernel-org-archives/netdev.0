From: Gabriel C <nix.or.die@googlemail.com>
Subject: Re: net/ipv4/fib_trie.c - compile error (Re: 2.6.23-rc3-mm1)
Date: Wed, 22 Aug 2007 18:32:04 +0200
Message-ID: <46CC6504.3020500@googlemail.com>
References: <20070822020648.5ea3a612.akpm@linux-foundation.org> <46CC5685.7090500@googlemail.com> <20070822154111.GI30705@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:35356 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761777AbXHVQd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 12:33:28 -0400
Received: by nf-out-0910.google.com with SMTP id g13so162003nfb
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 09:33:26 -0700 (PDT)
In-Reply-To: <20070822154111.GI30705@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Wed, Aug 22, 2007 at 05:30:13PM +0200, Gabriel C wrote:
>> Got it with a randconfig ( http://194.231.229.228/kernel/mm/2.6.23-rc3-mm1/r/randconfig-8 )
>>
>> ...
>>
>> net/ipv4/fib_trie.c: In function 'trie_rebalance':
>> net/ipv4/fib_trie.c:969: error: lvalue required as unary '&' operand
>> net/ipv4/fib_trie.c:971: error: lvalue required as unary '&' operand
>> net/ipv4/fib_trie.c:977: error: lvalue required as unary '&' operand
>> net/ipv4/fib_trie.c:980: error: lvalue required as unary '&' operand
>> ...
> 
> Side effect of the git-net removal, temporarily removing 
> immunize-rcu_dereference-against-crazy-compiler-writers.patch should 
> work around it.

Yes it does , thx Adrian

> 
> cu
> Adrian
> 

Gabriel
