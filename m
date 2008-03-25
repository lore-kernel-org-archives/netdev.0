From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Bugme-new] [Bug 10318] New: WARNING: at arch/x86/mm/highmem_32.c:43
 kmap_atomic_prot+0x87/0x184()
Date: Tue, 25 Mar 2008 12:01:37 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0803251159500.17356@schroedinger.engr.sgi.com>
References: <bug-10318-10286@http.bugzilla.kernel.org/>
 <20080325105750.ff913a83.akpm@linux-foundation.org> <47E9482B.7050005@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pstaszewski@artcom.pl,
	linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:40242 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753683AbYCYTDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 15:03:32 -0400
In-Reply-To: <47E9482B.7050005@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Mar 2008, Eric Dumazet wrote:

> If kzalloc() or __get_free_pages(__GFP_ZERO) is not allowed from softirq then
> many usages are illegal.

There is clearly no problem for GFP_KERNEL. The only issue could arise for 
GFP_HIGHMEM|__GFP_ZERO. I thought we had dealt with these false positives 
a while back?

