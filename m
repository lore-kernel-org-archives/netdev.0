From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] fix sparse warnings
Date: Sat, 12 Jan 2008 21:28:01 -0800 (PST)
Message-ID: <20080112.212801.15911504.davem@davemloft.net>
References: <20080112064646.659443238@linux-foundation.org>
	<4788A17D.5070903@cosmosbay.com>
	<20080112130946.4d83eca7@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59741
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751121AbYAMF2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 00:28:01 -0500
In-Reply-To: <20080112130946.4d83eca7@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Sat, 12 Jan 2008 13:09:46 -0800

> On Sat, 12 Jan 2008 12:16:13 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> > [FIB]: Reduce text size of net/ipv4/fib_trie.o
> > 
> > In struct tnode, we use two fields of 5 bits for 'pos' and 'bits'.
> > Switching to plain 'unsigned char' (8 bits) take the same space
> > because of compiler alignments, and reduce text size by 435 bytes
> > on i386.
> > 
> > On i386 :
> > $ size net/ipv4/fib_trie.o.before_patch net/ipv4/fib_trie.o
> >     text    data     bss     dec     hex filename
> >    13714       4      64   13782    35d6 net/ipv4/fib_trie.o.before
> >    13279       4      64   13347    3423 net/ipv4/fib_trie.o
> > 
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> > 
> 
> I agree they should not have been bitfields in the first place.

Applied.
