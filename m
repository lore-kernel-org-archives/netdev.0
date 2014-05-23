From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] lib/test_bpf.c: don't use gcc union shortcut
Date: Fri, 23 May 2014 15:09:41 -0400 (EDT)
Message-ID: <20140523.150941.507220963556617584.davem@davemloft.net>
References: <20140522171646.843C831C19E@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbaEWTJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 15:09:43 -0400
In-Reply-To: <20140522171646.843C831C19E@corp2gmr1-1.hot.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 22 May 2014 10:16:46 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: lib/test_bpf.c: don't use gcc union shortcut
> 
> Older gcc's (mine is gcc-4.4.4) make a mess of this.
> 
> lib/test_bpf.c:74: error: unknown field 'insns' specified in initializer
> lib/test_bpf.c:75: warning: missing braces around initializer
> lib/test_bpf.c:75: warning: (near initialization for 'tests[0].<anonymous>.insns[0]')
> lib/test_bpf.c:76: error: extra brace group at end of initializer
> lib/test_bpf.c:76: error: (near initialization for 'tests[0].<anonymous>')
> lib/test_bpf.c:76: warning: excess elements in union initializer
> lib/test_bpf.c:76: warning: (near initialization for 'tests[0].<anonymous>')
> lib/test_bpf.c:77: error: extra brace group at end of initializer
> 
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks Andrew.
