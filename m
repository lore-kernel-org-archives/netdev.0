From: Gabriel C <nix.or.die@googlemail.com>
Subject: net/ipv4/fib_trie.c - compile error (Re: 2.6.23-rc3-mm1)
Date: Wed, 22 Aug 2007 17:30:13 +0200
Message-ID: <46CC5685.7090500@googlemail.com>
References: <20070822020648.5ea3a612.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:9570 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760922AbXHVPbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 11:31:36 -0400
Received: by nf-out-0910.google.com with SMTP id g13so146921nfb
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 08:31:34 -0700 (PDT)
In-Reply-To: <20070822020648.5ea3a612.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Got it with a randconfig ( http://194.231.229.228/kernel/mm/2.6.23-rc3-mm1/r/randconfig-8 )

...

net/ipv4/fib_trie.c: In function 'trie_rebalance':
net/ipv4/fib_trie.c:969: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c:971: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c:977: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c:980: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c: In function 'fib_insert_node':
net/ipv4/fib_trie.c:1034: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c:1034: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c:1034: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c: In function 'fn_trie_lookup':
net/ipv4/fib_trie.c:1498: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c:1502: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c:1502: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c:1503: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c: In function 'trie_leaf_remove':
net/ipv4/fib_trie.c:1539: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c:1539: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c:1539: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c:1554: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c: In function 'nextleaf':
net/ipv4/fib_trie.c:1706: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c:1743: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c: In function 'fib_trie_get_next':
net/ipv4/fib_trie.c:2046: error: lvalue required as unary '&' operand
net/ipv4/fib_trie.c: In function 'fib_trie_seq_show':
net/ipv4/fib_trie.c:2320: error: lvalue required as unary '&' operand
make[2]: *** [net/ipv4/fib_trie.o] Error 1
make[1]: *** [net/ipv4] Error 2
make: *** [net] Error 2
make: *** Waiting for unfinished jobs....

...
