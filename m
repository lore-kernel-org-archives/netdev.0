From: David Miller <davem@davemloft.net>
Subject: Re: [FIB]: Avoid using static variables without proper locking
Date: Mon, 14 Jan 2008 23:10:26 -0800 (PST)
Message-ID: <20080114.231026.65586727.davem@davemloft.net>
References: <478B9D0B.5040301@cosmosbay.com>
	<18315.41725.417992.715140@robur.slu.se>
	<478BB78F.8060609@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40544
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750852AbYAOHKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 02:10:33 -0500
In-Reply-To: <478BB78F.8060609@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 14 Jan 2008 20:27:11 +0100

> fib_trie_seq_show() uses two helper functions, rtn_scope() and 
> rtn_type() that can
> write to static storage without locking.
> 
> Just pass to them a temporary buffer to avoid potential  corruption
> (probably not triggerable but still...)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to net-2.6.25, but I had to tweak it to apply
cleanly since the %d in rtn_type() is now a %u
