From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv4: Remove fib_hash.
Date: Tue, 1 Feb 2011 15:26:03 -0800
Message-ID: <20110201152603.3ce5bd26@nehalam>
References: <20110201.151941.48509941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46054 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751789Ab1BAX0G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Feb 2011 18:26:06 -0500
In-Reply-To: <20110201.151941.48509941.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Feb 2011 15:19:41 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> 
> The time has finally come to remove the hash based routing table
> implementation in ipv4.
> 
> FIB Trie is mature, well tested, and I've done an audit of it's code
> to confirm that it implements insert, delete, and lookup with the same
> identical semantics as fib_hash did.
> 
> If there are any semantic differences found in fib_trie, we should
> simply fix them.
> 
> I've placed the trie statistic config option under advanced router
> configuration.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Vyatta has been shipping FIB TRIE for over 3 years with reported
bugs.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
